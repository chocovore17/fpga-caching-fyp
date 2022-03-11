/*
 * Finite state machine.
 * IDLE -> STATE_UPDATE_MEM when ack goes high 
 * STATE_UPDATE_MEM -> IDLE when memwr goes low 
 */ 
module downstream_processor(clk, ack, memwr, out);
  input  clk;
  input ack; // how to ensure it will go back to 0?
  input memwr; // how to ensure it will go back to 0?
  output out;
  
  reg [1:0] state;

  // State encodings
  parameter [1:0]
    IDLE    = 2'b01,
    STATE_UPDATE_MEM = 2'b10;
    
  // State machine output
  assign out = (state == STATE_UPDATE_MEM);  
  // State transitions
  always @(posedge clk, ack, memwr) begin
    case (state)
      IDLE:
        if (ack) begin
          state <= STATE_UPDATE_MEM;
        end else begin
          state <= IDLE;
        end
      STATE_UPDATE_MEM:
        if (memwr) begin
          state <= IDLE;
        end else begin
          state <= STATE_UPDATE_MEM;
        end
      default:
        state <= IDLE;
    endcase
  end

endmodule