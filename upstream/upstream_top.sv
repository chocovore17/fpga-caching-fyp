/*
 * top level to call different modules in upstream
 compile with the following flags in icarus verilog:  -Wall -g2012 bc inputs/outputs fed back
 */ 

 `include "../shared/ramdownstream.sv"
 `include "../shared/ramupstream.sv"
 `include "upstream.sv"
 `include "SLT.sv"

module upstream_processor_top(clk, client_id, amount, out, new_order, new_max);
  input  clk, new_order, new_max; // for now use same clock to read and write, just not at same time
  input[4:0]  client_id;
  input[31:0] amount;
  output out;
  
  reg pass_checks; //state machine input
  reg upstream_enable, downstream_enable; //RAM inputs
  reg [9:0] upstreamclient_id; //RAM inputs
  reg  [4:0] address_write; //RAM inputs
  reg       check_risk, send_order, update_max; // state machine outputs
  wire [31:0] cancelled_orders, max_to_trade, accumulated_orders; // RAM data OUTPUTS
  reg memwr, nocare; // RAM bool output & State machine input, don't care about downstream

  // instantiate upstream ram (should it be done here? )
  ramupstream #(32, 10, 1024) RAMUPSTREAM (
    .clk_write(clk),
    .change_max(update_max),
    .address_write(upstreamclient_id),
    .data_write(amount),
    .write_enable(upstream_enable),
    .clk_read(clk),
    .address_read(upstreamclient_id),
    .accumulated_orders(accumulated_orders),
    .max_to_trade(max_to_trade));
    .memwr(memwr),                              // output 

  // instantiate downstream ram (should it be done here? )
  ramdownstream #(32, 5, 32) RAMDOWNSTREAM (
    .clk_write(clk),                            // input 
    .downstream_address_write(client_id),       // input 
    .data_write(amount),                        // input[31:0] 
    .downstream_write_enable(downstream_enable),// input 
    .clk_read(clk),                             // input 
    .address_read(client_id),                   // input [4:0]
    .memwr(nocare),                              // output 
    .data_read(cancelled_orders));              // output[31:0]

    // outputs the risk check value
    SLT SLT(.A(max_to_trade),
        .B(accumulated_orders + amount + (~cancelled_orders + 1)),
        .Result(pass_checks));

  //instantiate upstream state machine to know current state 
    upstream_processor UPSTREAMPROCESSOR(.clk(clk),
          .risk_ok(pass_checks),
          .new_order(new_order),
          .new_max(new_max),
          .memwr(memwr),
          .check_risk(check_risk),
          .send_order(send_order),
          .update_max(update_max));

  // always @(client_id,amount)
  // begin

  // end

endmodule