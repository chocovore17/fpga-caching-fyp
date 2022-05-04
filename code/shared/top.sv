/*
 * top level to call different modules in upstream
 compile with the following flags in icarus verilog:  -Wall -g2012 bc inputs/outputs fed back
 */ 

//  `include "ramdownstream.sv"
//  `include "ramupstream.sv"
 `include "code/upstream/upstream_top.sv"
 `include "code/downstream/downstream_top.sv"
//  `include "code/upstream/SLT.sv"

 `include "code/shared/cache_def.sv"
 import cache_def::*;

 `define SAFE (max_to_trade >  (accumulated_orders - cancelled_orders )) 

module top( clk, HRESETn, cpu_client_id, cpu_amount, cpu_go, cpu_new_max, exchange_client_id, exchange_amount, exchange_go, /*to display testing*/ cancelled_orders, accumulated_orders , max_to_trade);
  // input and outputs
  input[4:0]  exchange_client_id;
  input[15:0] exchange_amount;
  input[4:0]  cpu_client_id;
  input HRESETn, exchange_go;

  input[15:0] cpu_amount;
  input cpu_go, cpu_new_max; // for now use same clock to read and write, just not at same time
  input clk;
  output [15:0] cancelled_orders;
  output [15:0] accumulated_orders;
  output[31:0] max_to_trade;
  cache_req_type downdatareq;
  // downdatareq.rdindex  = cpu_client_id;


  // downstream ram 
  dm_data_downstream RAMDOWNSTREAM(
    .clk(clk),
    .data_req(downdatareq),
    .data_write({96'b0, exchange_amount}),
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
   .thenewmax(thenewmax),
   .cancelled_orders(cancelled_orders)
   );
 
   downstream_top DOWNTOP(
    .clk(clk), 
    .client_id(exchange_client_id), 
    .amount(exchange_amount), 
    .downdatareq(downdatareq),
    .cpu_client_id(cpu_client_id)
    );

    always @(cpu_client_id) begin
      downdatareq.rdindex  = cpu_client_id;
      $display("cancelled : 0x%0h", cancelled_orders);
    end
  
    
        
    // ____________________________________________ CHECKS ALWAYS SAFE TO TRADE _________________________________________//

  // // SVA to check if gpio_out during reset
  //   trade_risk_check: assert property (
  //     @(posedge clk) // throws an error if the trade is unsafe
  //     `SAFE == 1'b1
  //       )
  //     else begin
  //       $error ("The trade is not safe for client %0b; max to trade: %0b, accumulated amount: %0b, cancelled: %0b, pass check %0b", cpu_client_id, max_to_trade, accumulated_orders, cancelled_orders, pass_checks);
  //     end //
         

endmodule