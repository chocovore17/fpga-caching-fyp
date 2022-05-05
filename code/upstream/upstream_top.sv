/*
 * top level to call different modules in upstream
 compile with the following flags in icarus verilog:  -Wall -g2012 bc inputs/outputs fed back
 */ 

 `include "code/shared/ramdownstream.sv"
 `include "code/shared/ramupstream.sv"
 `include "upstream.sv"
 `include "SLT.sv"
//  `include "code/shared/rom_trade.mem"
//  `define SAFE ($signed({1'b0, max_to_trade[15:0]})> $signed(accumulated_orders+ (~cancelled_orders+1)))

 `define SAFETOTRADE  ($signed({1'b0, max_to_trade_reg[15:0]})> $signed(result))

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
  input [15:0] cancelled_orders; // RAM data 
  reg [15:0] result, accumulated_orders_reg, cancelled_orders_reg ; // for signed comp 
  output [15:0] accumulated_orders;
  output[31:0] max_to_trade;
  reg [31:0] max_to_trade_reg ;
  reg memwr, nocare; // RAM bool output & State machine input, don't care about downstream
  assign thenewmax = update_max;
  // // instantiate upstream ram 
  assign accumulated_orders =  accumulated_orders_reg ;
  assign max_to_trade =  max_to_trade_reg ;


  // assign cancelled_orders = mem_datadown;

  dm_data_upstream RAMUPSTREAM(
    .clk(clk),    
    .data_req(mem_requp),    //CPU request input (CPU->cache)
    .data_write(mem_dataup_wr),     //memory response (memory->cache)
    .data_read(mem_dataup)    //memory request (cache->memory)
    );



  //instantiate upstream state machine to know current state 
    upstream_processor UPSTREAMPROCESSOR(.clk(clk),
          .risk_ok(pass_checks),
          .new_order(new_order),
          .HRESETn(1'b1),
          .new_max(new_max),
          .memwr(memwr),
          .check_risk(check_risk),
          .send_order(send_order),
          .update_max(update_max));

  always @(client_id, amount) begin
  begin 
    mem_requp.rdindex = client_id[9:0];
    accumulated_orders_reg = mem_dataup[15:0];
    cancelled_orders_reg =  cancelled_orders;
    max_to_trade_reg = mem_dataup >> 16;
    if ((new_max) && (amount>(mem_dataup[15:0])) ) // update max, shift amount 16 bits to left
      correct_amount = amount << 16;
    else
      correct_amount = amount;
      // no need for an else, amount is less then 16

    mem_dataup_wr = correct_amount;
    result = (accumulated_orders_reg+ (~cancelled_orders_reg+1) + amount );
    // $display("%0b, result : %0d",($signed({1'b0, max_to_trade[15:0]})>$signed(result) ),$signed(result) );
    pass_checks = $signed({1'b0, max_to_trade_reg[15:0]})>$signed(result); //extend for neg values
    mem_requp.we = pass_checks;
  end 
  
    
  // SVA to check if trade safe respected
  trade_pass_checks: assert property (
    @(posedge clk) // throws an error if the trade is unsafe
    `SAFETOTRADE == pass_checks
      )
    else begin 
      $error ("pass_checks was not computer properly for client %0d; max to trade: %0d, accumulated amount: %0d, cancelled amount: %0d, pass_checks: %0d, amount %0d", client_id, max_to_trade, accumulated_orders, cancelled_orders, pass_checks, amount);
    end //

    // SVA to check if CORRECT amount written
    trade_correctamount_cpu: assert property (
      @(posedge clk) // throws an error if the correct amount is different from amount to trade
       (correct_amount == amount) || (correct_amount[31:16]== amount)
        )
      else begin 
        $error ("The amount was not indexed properly: amount %0h; correct amount (to write): %0h", amount, correct_amount);
      end //

      
    // // SVA to check if state logic 
    // trade_state_logic: assert property (
    //   @(posedge clk) // throws an error if the trade is unsafe
    //   `SAFE == 1'b1
    //     )
    //   else begin 
    //     $error ("The trade is not SAFE for client %0h; max to trade: %0h, accumulated amount: %0h, cancelled amount: %0h, pass_checks: %0h", client_id, max_to_trade, accumulated_orders, cancelled_orders, pass_checks);
    //   end //
end 


endmodule