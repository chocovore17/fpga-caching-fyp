/*
 * top level to call different modules in upstream
 compile with the following flags in icarus verilog:  -Wall -g2012 bc inputs/outputs fed back
 */ 

 `include "code/shared/ramdownstream.sv"
 `include "code/shared/ramupstream.sv"
 `include "upstream.sv"
 `include "SLT.sv"
//  `include "code/shared/rom_trade.mem"

module upstream_processor_top(clk, client_id, amount, new_order, new_max, accumulated_orders, max_to_trade, thenewmax, cancelled_orders);
  input  clk, new_order, new_max; // for now use same clock to read and write, just not at same time
  input[4:0]  client_id;
  input[15:0] amount;
  output thenewmax;
  reg HRESETn;
  reg[31:0] correct_amount;
  reg pass_checks; //state machine input
  reg upstream_enable ; //RAM inputs
  
  cache_data_type mem_dataup_wr, mem_dataup, mem_datadown, mem_datadown_wr;
  cache_req_type mem_requp, mem_reqdown;

  reg       check_risk, send_order, update_max; // state machine outputs
  input [31:0] cancelled_orders; // RAM data 
  output [15:0] accumulated_orders;
  output[31:0] max_to_trade;
  reg memwr, nocare; // RAM bool output & State machine input, don't care about downstream
  assign thenewmax = update_max;
  // instantiate upstream ram (should it be done here? )
  assign HRESETn = 1'b0;
  assign accumulated_orders = mem_dataup[15:0];
  assign max_to_trade = mem_dataup >> 16;
  assign cancelled_orders = mem_datadown;

  dm_data_upstream RAMUPSTREAM(
    .clk(clk),    
    .data_req(mem_requp),    //CPU request input (CPU->cache)
    .data_write(mem_dataup_wr),     //memory response (memory->cache)
    .data_read(mem_dataup)    //memory request (cache->memory)
    );

    
  // dm_data_downstream RAMDOWNSTREAM(
  //   .clk(clk),    
  //   .data_req(mem_reqdown),    //CPU request input (CPU->cache)
  //   .data_write(mem_datadown_wr),     //memory response (memory->cache)
  //   .data_read(mem_datadown)    //memory request (cache->memory)
  //   );


  //instantiate upstream state machine to know current state 
    upstream_processor UPSTREAMPROCESSOR(.clk(clk),
          .risk_ok(pass_checks),
          .new_order(new_order),
          .new_max(new_max),
          .memwr(memwr),
          .check_risk(check_risk),
          .send_order(send_order),
          .update_max(update_max));

  always @(client_id, amount) begin
  begin 
    mem_requp.rdindex = client_id[9:0];
      if ((new_max) & (new_max>(mem_dataup)) ) // update max, shift amount 16 bits to left
      correct_amount = amount << 16;
    else
      correct_amount = amount;
      // no need for an else, amount is less then 16

    mem_dataup_wr = correct_amount;
    pass_checks <= max_to_trade>(accumulated_orders + amount - cancelled_orders);
    mem_requp.we = pass_checks;
  end 
  
  //   // SVA to check if gpio_out during reset
  trade_risk_check_cpu: assert property (
    @(posedge clk) // throws an error if the trade is unsafe
     max_to_trade> accumulated_orders
      )
    else begin 
      $error ("The trade is not SAFE for client %0h; max to trade: %0h, accumulated amount: %0h, pass_checks: %0h", client_id, max_to_trade, accumulated_orders, pass_checks);
    end //
end 


endmodule