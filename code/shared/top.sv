/*
 * top level to call different modules in upstream
 compile with the following flags in icarus verilog:  -Wall -g2012 bc inputs/outputs fed back
 */ 

 `include "ramdownstream.sv"
 `include "ramupstream.sv"
//  `include "code/downstream/downstream.sv"
 
//  `include "../downstream/get_cxl.sv"

 `include "code/upstream/upstream.sv"
 `include "code/upstream/SLT.sv"

 `include "code/shared/cache_def.sv"
 import cache_def::*;


module top( clk, HRESETn, cpu_client_id, cpu_amount, cpu_go, cpu_new_max, exchange_client_id, exchange_amount, exchange_go, /*to display testing*/ cancelled_orders, accumulated_orders , max_to_trade);
  input[4:0]  cpu_client_id, exchange_client_id;
  input clk, cpu_go, HRESETn, exchange_go, cpu_new_max;
  input[15:0] exchange_amount;
  output [15:0] cancelled_orders;
  input[31:0] cpu_amount;
  
  cache_req_type downdatareq, updatareq;
  cache_data_type downdatawrite, downdataread;
//   DOWNSTREAM
  reg ack; //state machine input - should be in a @new stuff instead and manually set ack to 1 
  reg update_memory; //RAM inputs, state machine output by default 0
  // reg memwr; // RAM bool output & State machine input
  reg[4:0] client_id;
  reg [9:0] upstreamclient_id; //RAM inputs

// UPSTREAM
  reg pass_checks; //state machine input
  reg upstream_enable ; //RAM inputs
  reg       check_risk, send_order, update_max; // state machine outputs
  wire [15:0] cancelled_orders; // RAM data OUTPUTS
  output [31:0] accumulated_orders;
  output[31:0] max_to_trade;
  reg [111:0] toc;
  reg memwr_up; //, memwr_down ; // RAM bool output & State machine input, for both downstream and upstream 

  // downstream ram 
  dm_data_upstream RAMUPSTREAM(
    .clk(clk),
    .data_req(updatareq),
    .change_max(update_max),
    .data_write({112'b0, cpu_amount}),
    .accumulated_orders(accumulated_orders),
    .max_to_trade(max_to_trade)  
    );


  // downstream ram 
  dm_data_downstream RAMDOWNSTREAM(
    .clk(clk),
    .data_req(downdatareq),
    .data_write({112'b0, exchange_amount}),
    .data_read({toc,cancelled_orders})
  );

  // // instantiate upstream ram 
  // ramupstream #(32, 10, 1024) RAMUPSTREAM (
  //   .clk_write(clk),
  //   .change_max(update_max),
  //   .address_write({5'b0, cpu_client_id}),
  //   .data_write(cpu_amount),
  //   .write_enable((update_max) || (send_order)),
  //   .clk_read(clk),
  //   .address_read({5'b0, cpu_client_id}),
  //   .accumulated_orders(accumulated_orders),
  //   .max_to_trade(max_to_trade),
  //   .memwr(memwr_up));                             // output 

    // outputs the risk check value
    SLT SLT(.A(max_to_trade),
        .B(accumulated_orders + cpu_amount + (~cancelled_orders + 1)),
        .Result(pass_checks));

  //instantiate upstream state machine to know current state 
    upstream_processor UPSTREAMPROCESSOR(.clk(clk),
          .risk_ok(pass_checks),
          .new_order(cpu_go & (~cpu_new_max)),
          .new_max(cpu_new_max),
          .HRESETn(HRESETn),
          .memwr(memwr_up),
          .check_risk(check_risk),
          .send_order(send_order),
          .update_max(update_max));

  always @(cpu_go,exchange_go, cpu_new_max)
  begin
    // $display(check_risk,send_order,  update_max);
    
      if (exchange_go ==1)
        begin 
            // client_id = exchange_client_id;
            // amount = exchange_amount;
            downdatareq.index = exchange_client_id;
            downdatareq.we =exchange_go;
        end
        else  begin  //default should be cpu 
            client_id = cpu_client_id;
            downdatareq.index = cpu_client_id;            
            updatareq.index = cpu_client_id;
            updatareq.we = ~exchange_go;
            downdatareq.we =0;
        end 

  end

endmodule