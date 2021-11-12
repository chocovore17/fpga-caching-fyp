/*
 * top level to call different modules in upstream
 compile with the following flags in icarus verilog:  -Wall -g2012 bc inputs/outputs fed back
 */ 

 `include "../shared/ramdownstream.sv"
 `include "downstream.sv"

module downstream_top(ack, client_id, amount, cancelled_orders /*to display testing*/);
  reg  clk; // for now use same clock to read and write, just not at same time
  input[4:0]  client_id;
  input[31:0] amount;
  output [31:0] cancelled_orders;
  
  input ack; //state machine input - should be in a @new stuff instead and manually set ack to 1 
  reg update_memory; //RAM inputs, state machine output by default 0
  reg [31:0] total_cancel; // RAM data OUTPUTS
  reg memwr; // RAM bool output & State machine input


  // instantiate downstream ram (should it be done here? )
  ramdownstream #(32, 5, 32) RAMDOWNSTREAM (
    .clk_write(clk),                            // input 
    .downstream_address_write(client_id),       // input 
    .data_write(total_cancel),       // input[31:0]  // check that it doesn't mix for client with pipeline 
    .downstream_write_enable(update_memory),// input 
    .clk_read(clk),                             // input 
    .address_read(client_id),                   // input [4:0]
    .memwr(memwr),                              // output 
    .data_read(cancelled_orders));              // output[31:0]

  //instantiate upstream state machine to know current state 
  downstream_processor DOWNSTREAMPROCESSOR(.clk(clk),
          .ack(ack),
          .memwr(memwr),
          .out(update_memory));

  always @(client_id) begin
      total_cancel <= amount+cancelled_orders;
      toggle_clk;
  end 

  
  task toggle_clk;
    begin
      #10 clk = ~clk;
      #10 clk = ~clk;
    end
  endtask

endmodule