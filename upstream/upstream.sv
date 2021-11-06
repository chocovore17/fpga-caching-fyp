/*
 * Finite state machine.
 * IDLE -> STATE_UPDATE_MEM when ack goes high 
//  * STATE_UPDATE_MEM -> IDLE when memwr goes low 
//  */ 
// module upstream_processor(clk, ack, memwr, out);
//   input  clk;
//   input  ack;
//   input memwr;
//   output out;
  
//   reg [1:0] state;

//   // State encodings
//   parameter [2:0]
//     IDLE    = 2'b01,
//     STATE_UPDATE_MEM = 2'b10,
    
//   // State machine output
//   assign out = (state == STATE_UPDATE_MEM);
  
//   // State transitions
//   always @(posedge clk) begin
//     case (state)
//       IDLE:
//         if (ack) begin
//           state <= STATE_UPDATE_MEM;
//           ack <= 1'b0 //is it how to reset ack
//         end else begin
//           state <= IDLE;
//         end
//       STATE_UPDATE_MEM:
//         if (memwr) begin
//           state <= IDLE;
//           memwr <= 1'b0 //is it how to reset memwr
//         end else begin
//           state <= STATE_UPDATE_MEM;
//         end
//       default:
//         state <= IDLE;
//         ack <= 1'b0 //is it how to reset ack
//         memwr <= 1'b0 //is it how to reset memwr
//     endcase
//   end

// endmodule