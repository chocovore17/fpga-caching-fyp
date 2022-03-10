/*
 * top level to call different modules in upstream
 compile with the following flags in icarus verilog:  -Wall -g2012 bc inputs/outputs fed back
 */ 

 `include "ramdownstream.sv"
 `include "ramupstream.sv"
 `include "code/downstream/downstream.sv"
//  `include "../downstream/get_cxl.sv"

 `include "code/upstream/upstream.sv"
 `include "code/upstream/SLT.sv"


module top( clk, cpu_client_id, cpu_amount, cpu_go, cpu_new_max, exchange_client_id, exchange_amount, exchange_go, /*to display testing*/ cancelled_orders, accumulated_orders );
  input[4:0]  cpu_client_id, exchange_client_id;
  input clk, cpu_go, exchange_go, cpu_new_max;
  input[15:0] exchange_amount;
  output [15:0] cancelled_orders;
  input[31:0] cpu_amount;
  
//   DOWNSTREAM
  reg ack; //state machine input - should be in a @new stuff instead and manually set ack to 1 
  reg update_memory; //RAM inputs, state machine output by default 0
  reg memwr; // RAM bool output & State machine input
  reg[15:0] amount;
  reg[4:0] client_id;

// UPSTREAM
  reg pass_checks; //state machine input
  reg upstream_enable ; //RAM inputs
  reg       check_risk, send_order, update_max; // state machine outputs
  wire [15:0] cancelled_orders; // RAM data OUTPUTS
  output [31:0] accumulated_orders;
  reg[31:0] max_to_trade;
  reg memwr_up, memwr_down ; // RAM bool output & State machine input, for both downstream and upstream 

  // instantiate downstream ram 
  ramdownstream #(16, 5, 32) RAMDOWNSTREAM (
    .clk_write(clk),                            // input 
    .downstream_address_write(client_id),       // input 
    .data_write(amount),       // input[15:0]  // check that it doesn't mix for client with pipeline 
    .downstream_write_enable(update_memory),// input 
    .clk_read(clk),                             // input 
    .address_read(client_id),                   // input [4:0]
    .memwr(memwr_down),                              // output 
    .data_read(cancelled_orders));              // output[15:0]


  //instantiate upstream state machine to know current state 
  downstream_processor DOWNSTREAMPROCESSOR(.clk(clk),
          .ack(cpu_go),    //new cancel or not 
          .memwr(memwr_down), //input from ramdownstream
          .out(update_memory)); //output for state machine

    // instantiate upstream ram 
  ramupstream #(32, 5, 32) RAMUPSTREAM (
    .clk_write(clk),
    .change_max(update_max),
    .address_write(cpu_client_id),
    .data_write(cpu_amount),
    .write_enable((update_max) || (send_order)),
    .clk_read(clk),
    .address_read(cpu_client_id),
    .accumulated_orders(accumulated_orders),
    .max_to_trade(max_to_trade),
    .memwr(memwr_up));                             // output 


    // outputs the risk check value
    SLT SLT(.A(max_to_trade),
        .B(accumulated_orders + cpu_amount + (~cancelled_orders + 1)),
        .Result(pass_checks));

  //instantiate upstream state machine to know current state 
    upstream_processor UPSTREAMPROCESSOR(.clk(clk),
          .risk_ok(pass_checks),
          .new_order(cpu_go & (~cpu_new_max)),
          .new_max(cpu_go & cpu_new_max),
          .memwr(memwr_up),
          .check_risk(check_risk),
          .send_order(send_order),
          .update_max(update_max));

  always @(cpu_go,exchange_go)
  begin
      if (exchange_go ==1)
        begin 
            client_id = exchange_client_id;
            amount = exchange_amount;
        end
        else  begin  //default should be cpu 
            client_id = cpu_client_id;
            amount = cpu_amount[15:0];
        end 

  end

endmodule