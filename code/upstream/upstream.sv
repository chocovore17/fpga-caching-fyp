/*
 * Finite state machine.
 * 4 main states (IDLE, RISKCHECK, SENDORDER, NEWMAX), 2 intermediate states (RISKCHK_SENDORDER, RISKCHECK_NEWMAX)
 */ 
module upstream_processor(clk, risk_ok, new_order, new_max, memwr, check_risk, send_order, update_max);
  input  clk;
  input risk_ok; // bool - 0 = pass, 1 = fails 
  input new_order; // bool
  input new_max; // bool
  input memwr; // bool
  output check_risk;
  output send_order;
  output update_max;

  
  reg [4:0] state;

  // State encodings ONE HOT
  parameter [4:0]
    IDLE                    = 6'b00001,
    STATE_RISKCHECK         = 6'b00010,
    STATE_SENDORDER         = 6'b00100,
    STATE_NEWMAX            = 6'b01000,
    STATE_RISKCHK_SENDORDER = 6'b10000;
    // STATE_RISKCHECK_NEWMAX  = 6'b100000, //shouldn't be possible, will add if find a way for speedup

  // State machine output
  // assign check_risk = ((state == STATE_RISKCHECK)||(state == STATE_RISKCHK_SENDORDER));  //||(state == STATE_RISKCHECK_NEWMAX) 
  // assign send_order = ((state == STATE_SENDORDER)||(state == STATE_RISKCHK_SENDORDER));  
  assign check_risk = (state == STATE_RISKCHECK); //||(state == STATE_RISKCHECK_NEWMAX) 
  assign send_order = (state == STATE_SENDORDER);
  assign update_max = (state == STATE_NEWMAX);   //override if need to update maximum
  
  // State transitions
  // QUESTION - policy about new max - should we have an @always if new_max that has priority ?
  // for improvement: add state sendorder_newmax
  always @(posedge clk, risk_ok, new_max, new_order, memwr) begin
    case (state)
      IDLE:
        if ((new_order==1'b0)&&(new_max==1'b1)) begin
          state <= STATE_NEWMAX;
        end else if ((new_order==1'b1)&&(new_max==1'b0)) begin
          state <= STATE_RISKCHECK;
        end else begin
          state <= IDLE;
        end

      STATE_RISKCHECK:
        if ((risk_ok==1'b1)&&(new_order==1'b0)&&(new_max==1'b0)) begin //pass risks check
          state <= STATE_SENDORDER;
        end else if((risk_ok==1'b0)&&(new_order==1'b1)&&(new_max==1'b0)) begin //fails risk checks
          state <= IDLE;
        end else if((risk_ok==1'b1)&&(new_order==1'b1)&&(new_max==1'b0)) begin // pass and new order 
          state <= STATE_RISKCHK_SENDORDER;
        end else if((risk_ok==1'b0)&&(new_order==1'b0)&&(new_max==1'b1)) begin
          state <= STATE_NEWMAX; // able to update new max from here if risk check fails  (speedup avoid clock cycle through IDLE)
        end else begin
          state <= STATE_RISKCHECK;
        end

      STATE_SENDORDER:
        if ((memwr==1'b1)&&(new_order==1'b0)&&(new_max==1'b0)) begin //wrote order to memory
          state <= IDLE;
        end else if((memwr==1'b1)&&(new_order==1'b1)&&(new_max==1'b0)) begin //wrote order to memory + new order (speedup avoid clock cycle through IDLE)
          state <= STATE_RISKCHECK;
        end else if((memwr==1'b0)&&(new_order==1'b1)&&(new_max==1'b0)) begin //did not write order to memory + new order (speedup avoid clock cycle through IDLE)
          state <= STATE_RISKCHK_SENDORDER;
        end else if((memwr==1'b1)&&(new_order==1'b0)&&(new_max==1'b1)) begin //wrote order to memory + new max (speedup avoid clock cycle through IDLE)
          state <= STATE_NEWMAX; // able to update new max from here if risk check fails without extra clock cycle 
        end else begin
          state <= STATE_SENDORDER;
        end

      STATE_NEWMAX:
        if ((memwr==1'b1)&&(new_order==1'b0)&&(new_max==1'b0)) begin //wrote new max to memory
          state <= IDLE;
        end else if((memwr==1'b1)&&(new_order==1'b1)&&(new_max==1'b0)) begin //wrote  new max  to memory + new order (speedup avoid clock cycle through IDLE)
          state <= STATE_RISKCHECK;
        end else begin
          state <= STATE_NEWMAX; // Must wait to write new max before doing anything else (kind of slow?)
        end


      // STATE_RISKCHK_SENDORDER: //might get stuck at this phase if send lots of orders fast ?
      //   if ((memwr==1'b1)&&(new_order==1'b0)&&(new_max==1'b1)&&(risk_ok==1'b0)) begin //wrote order to memory, fails risk check, want to update max
      //     state <= STATE_NEWMAX;
      //   end else if ((memwr==1'b1)&&(new_order==1'b0)&&(new_max==1'b0)&&(risk_ok==1'b0)) begin //wrote order to memory, fails risk check
      //     state <= IDLE;
      //   end else if((memwr==1'b1)&&(new_order==1'b0)&&(new_max==1'b0)&&(risk_ok==1'b1)) begin //wrote order to memory, passes risk check
      //     state <= STATE_SENDORDER;
      //   end else if((memwr==1'b0)&&(new_order==1'b0)&&(new_max==1'b0)&&(risk_ok==1'b0)) begin // did not write order to memory, fail risk check
      //     state <= STATE_SENDORDER;
      //   end else if((memwr==1'b1)&&(new_order==1'b0)&&(new_max==1'b1)&&(risk_ok==1'b0)) begin // wrote order to memory, fail risk check, new max 
      //     state <= STATE_NEWMAX;
      //   end else if((memwr==1'b1)&&(new_order==1'b1)&&(new_max==1'b0)&&(risk_ok==1'b0)) begin // wrote order to memory, fails risk check, new order 
      //     state <= STATE_RISKCHECK;
      //   end else begin
      //     state <= STATE_RISKCHK_SENDORDER;// did not write order to memory, passes risk check => discard order, 
      //   end

      default:
        state <= IDLE;
    endcase
  end

endmodule