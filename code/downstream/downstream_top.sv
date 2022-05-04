/*
 * top level to call different modules in upstream
 compile with the following flags in icarus verilog:  -Wall -g2012 bc inputs/outputs fed back
 */ 

//  `include "../shared/ramdownstream.sv"
 `include "code/shared/ramdownstream.sv"
//  `include "downstream.sv"
//  `include "get_cxl.sv"

 `include "code/shared/cache_def.sv"
 import cache_def::*;
module downstream_top( clk, client_id, amount, cancelled_orders /*to display testing*/);
  input[4:0]  client_id;
  input clk;
  input[15:0] amount;
  output [15:0] cancelled_orders;
  reg old_client;
  reg old_amount;
  cache_req_type downdatareq;
  cache_data_type downdatawrite, downdataread;
  reg ack; //state machine input - should be in a @new stuff instead and manually set ack to 1 
  reg update_memory; //RAM inputs, state machine output by default 0

  // downstream ram 
  dm_data_downstream RAMDOWNSTREAM(
    .clk(clk),
    .data_req(downdatareq),
    .data_write({96'b0, amount}),
    .data_read(cancelled_orders)
  );

  always @(client_id, amount)
  begin 
    // if (old_amount!= amount ||old_client!=client_id) ack <= 1'b1;
    $display("cancelled : %0h", cancelled_orders);
    downdatareq.index = client_id;
    downdatareq.we = ((client_id!=old_client) || (old_amount!=amount));
    old_amount = amount;
    old_client = client_id; 
  end 
endmodule

