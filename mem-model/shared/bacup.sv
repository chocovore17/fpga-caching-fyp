/*
 * top level to call different modules in upstream
 compile with the following flags in icarus verilog:  -Wall -g2012 bc inputs/outputs fed back
 */ 

 

 
 `include "mem-model/upstream/upstream_top.sv"
 `include "mem-model/downstream/downstream_top.sv"

 `include "mem-model/shared/cache_def.sv"
 import cache_def::*;

 `define SAFETOTRADE  ($signed({1'b0, max_to_trade[15:0]})> $signed(accumulated_orders+ (~cancelled_orders[15:0]+1)))

module top( clk, HRESETn, cpu_client_id, cpu_amount, cpu_go, cpu_new_max, exchange_client_id, exchange_amount, exchange_go, /*to display testing*/ cancelled_orders, accumulated_orders , max_to_trade);
  // input and outputs
  input[4:0]  exchange_client_id;
  input[15:0] exchange_amount;
  input[4:0]  cpu_client_id;
  input HRESETn, exchange_go;

  input[15:0] cpu_amount;
  input cpu_go, cpu_new_max; // for now use same clock to read and write, just not at same time
  input clk;
  output [31:0] cancelled_orders;
  output [15:0] accumulated_orders;
  output[31:0] max_to_trade;
  cache_req_type downdatareq;
  reg[4:0] exchange_client_id_reg;
  reg [15:0] exchange_amount_reg;


  // downstream ram 
  dm_data_downstream RAMDOWNSTREAM(
    .clk(clk),
    .data_req(downdatareq),
    .data_write({16'b0, exchange_amount_reg}),
    .data_read(cancelled_orders)
  );

  upstream_processor_top UPTOP(
   .clk(clk), 
   .client_id(cpu_client_id), 
   .amount(cpu_amount), 
   .new_order(cpu_go), 
   .new_max(cpu_new_max), 
   .accumulated_orders(accumulated_orders), 
   .max_to_trade(max_to_trade), 
   .done(done),
   .cancelled_orders(cancelled_orders[15:0])
   );
 
   downstream_top DOWNTOP(
    .clk(clk), 
    .client_id(exchange_client_id_reg), 
    .amount(exchange_amount_reg), 
    .downdatareq(downdatareq)
    // .cpu_client_id(cpu_client_id)
    );


    always @(cpu_client_id, exchange_client_id, cpu_go, cpu_new_max, exchange_go) begin
      fork 
        begin
      // cpu_client_id_reg= cpu_client_id;
      downdatareq.rdindex  = cpu_client_id;
      exchange_client_id_reg= exchange_client_id;
      exchange_amount_reg = exchange_amount;
      // wait(done == 1'b0 );
      // wait(done == 1'b1 );
    end
    begin
      if (done == 1'b0 )
      wait(done == 1'b1 );
    end
    join

  end    
    // ____________________________________________ CHECKS ALWAYS SAFE TO TRADE _________________________________________//

  

endmodule