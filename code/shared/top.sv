/*
 * top level to call different modules in upstream
 compile with the following flags in icarus verilog:  -Wall -g2012 bc inputs/outputs fed back
 */ 

 

 
 `include "code/upstream/upstream_top.sv"
 `include "code/downstream/downstream_top.sv"

 `include "code/shared/cache_def.sv"
 import cache_def::*;

 `define SAFETOTRADE  ($signed({1'b0, max_to_trade[15:0]})> $signed(accumulated_orders+ (~cancelled_orders[15:0]+1)))

module top( clk, HRESETn, cpu_client_id, cpu_amount, cpu_go, cpu_new_max, exchange_client_id, exchange_amount, exchange_go, /*to display testing*/ cancelled_orders, accumulated_orders , max_to_trade);
  // input and outputs
  input[4:0]  exchange_client_id;
  input[15:0] exchange_amount;
  input[9:0]  cpu_client_id;
  input HRESETn, exchange_go;

  input[15:0] cpu_amount;
  input cpu_go, cpu_new_max; // for now use same clock to read and write, just not at same time
  input clk;
  output [31:0] cancelled_orders;
  output [15:0] accumulated_orders;
  output[31:0] max_to_trade;
  
  reg[31:0] cancelled_orders_reg;
  cpu_req_type downdatareq; //CPU request input (CPU->cache)
  mem_data_type mem_data; //memory response (memory->cache)
  //outputs,
  mem_req_type mem_req; //memory request (cache->memory)
  cpu_result_type downexchrest; //cache result (cache->CPU)
 

  // assign downdatareq.rdindex[13:4]  = cpu_client_id;
  // assign downdatareq.rdindex[31:14]  = '0;
  // assign downdatareq.rdindex[3:0]  = '0;
  // assign  downdatareq.valid = 1'b1;
  // assign  downdatareq.data = exchange_amount;
  
  // assign cancelled_orders  = downexchrest.data;

  assign cancelled_orders  = cancelled_orders_reg;


  // // downstream ram 
  // dm_data_downstream RAMDOWNSTREAM(
  //   .clk(clk),
  //   .data_req(downdatareq),
  //   .data_write({16'b0, exchange_amount}),
  //   .data_read(cancelled_orders)
  // );

  
/*cache finite state machine*/
  dm_cache_fsm_downstream CACHEDOWNSTREAM(
    .clk(clk),
    //inputs: 
    .rst(1'b0), //no reset for now
    .cpu_req(downdatareq), //CPU request input (CPU->cache)
    .mem_data_down(mem_data), //memory response (memory->cache)
    // outputs:
    .mem_req(mem_req), //memory request (cache->memory) don't care here 
    .cpu_res(downexchrest) //cache result (cache->CPU)
    );

  upstream_processor_top UPTOP(
   .clk(clk), 
   .client_id(cpu_client_id), 
   .amount(cpu_amount), 
   .new_order(cpu_go), 
   .new_max(cpu_new_max), 
   .accumulated_orders(accumulated_orders), 
   .max_to_trade(max_to_trade), 
   .thenewmax(thenewmax),
   .cancelled_orders(cancelled_orders[15:0])
   );
 
   downstream_top DOWNTOP(
    .clk(clk), 
    .client_id(exchange_client_id), 
    .amount(exchange_amount), 
    .downdatareq(downdatareq)
    // .cpu_client_id(cpu_client_id)
    );

    always @(clk, downexchrest.ready) begin
    //   // always_comb begin

    //     downdatareq.wrindex[13:4] = exchange_client_id;
    //     downdatareq.rw = 1'b1; //((client_id!=old_client) || (old_amount!=amount));
        downdatareq.valid = 1'b1;
        downdatareq.data =exchange_amount;
    //     // old_amount = amount;
    //     // old_client = client_id;
    //     $display("downdatareq.rw",downdatareq.rw);
        downdatareq.rdindex[13:4]  = cpu_client_id;
        downdatareq.rdindex[31:14]  = '0;
        downdatareq.rdindex[3:0]  = '0;
    //     //  downdatareq.data  = exchange_amount;
        //  wait (downexchrest.ready === 1); //Implementation 1
        cancelled_orders_reg = downexchrest.data;
      end
        
    // ____________________________________________ CHECKS ALWAYS SAFE TO TRADE _________________________________________//

  

endmodule