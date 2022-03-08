/*
 * top level to call different modules in upstream
 compile with the following flags in icarus verilog:  -Wall -g2012 bc inputs/outputs fed back
 */ 

//  `include "../shared/ramdownstream.sv"
 `include "shared/ramdownstream.sv"
 `include "downstream.sv"
 `include "get_cxl.sv"

module downstream_top( clk, client_id, amount, cancelled_orders, memwr /*to display testing*/);
  input[4:0]  client_id;
  input clk;
  input[15:0] amount;
  output [15:0] cancelled_orders;
  
  reg ack; //state machine input - should be in a @new stuff instead and manually set ack to 1 
  reg update_memory; //RAM inputs, state machine output by default 0
  output memwr; // RAM bool output & State machine input


  // instantiate downstream ram (should it be done here? )
  ramdownstream #(16, 5, 32) RAMDOWNSTREAM (
    .clk_write(clk),                            // input 
    .downstream_address_write(client_id),       // input 
    .data_write(amount+cancelled_orders),       // input[15:0]  // check that it doesn't mix for client with pipeline 
    .downstream_write_enable(update_memory),// input 
    .clk_read(clk),                             // input 
    .address_read(client_id),                   // input [4:0]
    .memwr(memwr),                              // output 
    .data_read(cancelled_orders));              // output[31:0]


  //instantiate upstream state machine to know current state 
  downstream_processor DOWNSTREAMPROCESSOR(.clk(clk),
          .ack(ack),    //input from get_cxl
          .memwr(memwr), //input from ramdownstream
          .out(update_memory)); //output for state machine


  get_Cxl get_Cxl(.clk(clk), //input
          .client_id(client_id),  // input [4:0]
          .amount(amount),  // input[31:0]
          .ack(ack));       //output 

  // always @(posedge clk)
  // begin 
  //   ack = ack;
  //   memwr = memwr; 
  // end 
endmodule