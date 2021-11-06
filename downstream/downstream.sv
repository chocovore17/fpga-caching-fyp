/*
 * Finite state machine.
 * If input 'a' is asserted, the state machine
 * moves IDLE->STATE_1->FINAL and remains in FINAL.
 * If 'a' is not asserted, FSM returns to idle.
 * Output 'out1' asserts when state machine is in
 * STATE_1. 'out2' asserts when state machine is in
 * FINAL state.
 */ 
module downstream_processor(clk, ack, memwr, out);
  input  clk;
  input  ack;
  input memwr;
  output out;
  
  reg [1:0] state;

  // State encodings
  parameter [2:0]
    IDLE    = 2'b01,
    STATE_UPDATE_MEM = 2'b10,
    
  // State machine output
  assign out = (state == STATE_UPDATE_MEM);
  
  // State transitions
  always @(posedge clk) begin
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