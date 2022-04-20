/*
 * top level to call different modules in upstream
 compile with the following flags in icarus verilog:  -Wall -g2012 bc inputs/outputs fed back
 */ 

 `include "ramdownstream.sv"
 `include "ramupstream.sv"
 `include "code/upstream/upstream.sv"
 `include "code/upstream/SLT.sv"

 `include "code/shared/cache_def.sv"
 import cache_def::*;

 `define SAFE (max_to_trade >  (accumulated_orders - cancelled_orders ) 

module top( clk, HRESETn, cpu_client_id, cpu_amount, cpu_go, cpu_new_max, exchange_client_id, exchange_amount, exchange_go, /*to display testing*/ cancelled_orders, accumulated_orders , max_to_trade);
  input[4:0]  cpu_client_id, exchange_client_id;
  input clk, cpu_go, HRESETn, exchange_go, cpu_new_max;
  input[15:0] exchange_amount;
  output [15:0] cancelled_orders;
  output [15:0] accumulated_orders;
  output[31:0] max_to_trade;
  input[31:0] cpu_amount;
  cache_data_type mem_dataup_wr, mem_dataup, mem_datadown, mem_datadown_wr;
  cache_req_type mem_requp, mem_reqdown;

  assign accumulated_orders = mem_dataup[15:0];
  assign max_to_trade = mem_dataup >> 16;
  assign cancelled_orders = mem_datadown;

//   DOWNSTREAM
  reg ack; //state machine input - should be in a @new stuff instead and manually set ack to 1 
  reg update_memory; //RAM inputs, state machine output by default 0
  // reg memwr; // RAM bool output & State machine input
  reg[4:0] updated_up_client_id;

// UPSTREAM
  reg pass_checks; //state machine input
  reg upstream_enable ; //RAM inputs
  reg       check_risk, send_order, update_max; // state machine outputs
  reg [111:0] toc;
  reg memwr_up; //, memwr_down ; // RAM bool output & State machine input, for both downstream and upstream 


//   dm_cache_fsm_upstream RAMUPSTREAM(
//     .clk(clk),    
//     .rst(HRESETn),    
//     .cpu_req(cpu_requp),    //CPU request input (CPU->cache)
//     .mem_data(mem_data),     //memory response (memory->cache)
//     .mem_req(mem_requp),     //memory request (cache->memory)
//     .cpu_res(cpu_res_up)     //cache result (cache->CPU)
//     );
// /*cache finite state machine*/
//   dm_cache_fsm_downstream RAMDOWNSTREAM(
//     .clk(clk),    
//     .rst(HRESETn),    
//     .cpu_req(cpu_reqdown),    //CPU request input (CPU->cache)
//     .mem_data(mem_dataup),     //memory response (memory->cache)
//     .mem_req(mem_req),     //memory request (cache->memory)
//     .cpu_res(cpu_res)     //cache result (cache->CPU)
//     );

  dm_data_upstream RAMUPSTREAM(
    .clk(clk),    
    .data_req(mem_requp),    //CPU request input (CPU->cache)
    .data_write(mem_dataup_wr),     //memory response (memory->cache)
    .data_read(mem_dataup)    //memory request (cache->memory)
    );

    
  dm_data_downstream RAMDOWNSTREAM(
    .clk(clk),    
    .data_req(mem_reqdown),    //CPU request input (CPU->cache)
    .data_write(mem_datadown_wr),     //memory response (memory->cache)
    .data_read(mem_datadown)    //memory request (cache->memory)
    );


  //instantiate upstream state machine to know current state 
     upstream_processor UPSTREAMPROCESSOR(.clk(clk),
          .risk_ok(pass_checks),
          .new_order(cpu_go & (~cpu_new_max)),
          .new_max(cpu_new_max),
          .memwr(memwr_up),
          .check_risk(check_risk),
          .send_order(send_order),
          .update_max(update_max));

  always @(cpu_go,exchange_go, cpu_new_max)
  begin
    
      if ((exchange_go ==1)&(cpu_go==0))
        begin 
          mem_reqdown.index = exchange_client_id[9:0];
          mem_datadown_wr = exchange_amount;
          mem_reqdown.we = 1'b1
          // cpu_reqdown.addr   = {11'b1, exchange_client_id};
          // cpu_reqdown.data   = exchange_amount;
          // cpu_reqdown.rw   = exchange_go;
          // cpu_reqdown.valid   = 1;
          // mem_data.data = exchange_amount;
        end
      else  begin  //default should be cpu 
        mem_reqdown.we = 1'b0
        mem_reqdown.index = cpu_client_id[9:0];
        mem_requp.index = cpu_client_id[9:0];
        if ((cpu_new_max) & (cpu_amount>(mem_dataup)) ) // update max, shift amount 16 bits to left
          correct_amount = cpu_amount << 16;
        else
          correct_amount = cpu_amount;
        // no need for an else, amount is less then 16

          mem_dataup_wr = correct_amount;
          pass_checks <= max_to_trade>(accumulated_orders + amount - cancelled_orders);
          mem_requp.we = pass_checks;
        end 
        
    // ____________________________________________ CHECKS ALWAYS SAFE TO TRADE _________________________________________//

  // SVA to check if gpio_out during reset
    trade_risk_check: assert property (
      @(posedge clk) // throws an error if the trade is unsafe
      `SAFE == 1'b1
        )
      else begin
        $error ("The trade is not safe for client %0b; max to trade: %0b, accumulated amount: %0b, cancelled: %0b, pass check %0b", cpu_client_id, max_to_trade, accumulated_orders, cancelled_orders, pass_checks);
      end //
         

  end

endmodule