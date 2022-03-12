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


module top( clk, HRESETn, cpu_client_id, cpu_amount, cpu_go, cpu_new_max, exchange_client_id, exchange_amount, exchange_go, /*to display testing*/ cancelled_orders, accumulated_orders , max_to_trade);
  input[4:0]  cpu_client_id, exchange_client_id;
  input clk, cpu_go, HRESETn, exchange_go, cpu_new_max;
  input[15:0] exchange_amount;
  output [15:0] cancelled_orders;
  // wire [15:0] cancelled_orders; // RAM data OUTPUTS
  output [31:0] accumulated_orders;
  output[31:0] max_to_trade;
  input[31:0] cpu_amount;
  mem_data_type mem_data, mem_dataup;
  cpu_req_type cpu_reqdown, cpu_requp;
  mem_req_type mem_req, mem_requp;
  cpu_result_type cpu_res, cpu_res_up;
  cache_req_type  updatareq; //downdatareq,
  cache_data_type downdatawrite, downdataread;
  assign cancelled_orders = cpu_res.data;
  assign accumulated_orders = cpu_res_up.data[15:0];
  assign max_to_trade = cpu_res_up.data[31:15];

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


  dm_cache_fsm_upstream RAMUPSTREAM(
    .clk(clk),    
    .rst(HRESETn),    
    .cpu_req(cpu_requp),    //CPU request input (CPU->cache)
    .mem_data(mem_data),     //memory response (memory->cache)
    .mem_req(mem_requp),     //memory request (cache->memory)
    .cpu_res(cpu_res_up)     //cache result (cache->CPU)
    );
/*cache finite state machine*/
  dm_cache_fsm_downstream RAMDOWNSTREAM(
    .clk(clk),    
    .rst(HRESETn),    
    .cpu_req(cpu_reqdown),    //CPU request input (CPU->cache)
    .mem_data(mem_dataup),     //memory response (memory->cache)
    .mem_req(mem_req),     //memory request (cache->memory)
    .cpu_res(cpu_res)     //cache result (cache->CPU)
    );

    // outputs the risk check value
    SLT SLT(.A(max_to_trade),
        .B(accumulated_orders + cpu_amount + (~cpu_res.data + 1)),
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
          cpu_reqdown.addr   = exchange_client_id;
          cpu_reqdown.data   = exchange_amount;
          cpu_reqdown.rw   = exchange_go;
          cpu_reqdown.valid   = 1;
          mem_data.data = exchange_amount;
        end
        else  begin  //default should be cpu 
          if (cpu_new_max) // update max
            updated_up_client_id = cpu_client_id*2+1;
          else  begin // new order 
            updated_up_client_id = cpu_client_id*2;
          end

            cpu_reqdown.addr   = updated_up_client_id;         
            // updatareq.index = cpu_client_id;
            cpu_requp.addr   = updated_up_client_id;
            cpu_requp.data   = cpu_amount;
            mem_dataup.data = cpu_amount;
            cpu_requp.rw   =  ~exchange_go;;
            cpu_requp.valid   = 1;
            cpu_reqdown.rw   = 0;
        end 

  end

endmodule