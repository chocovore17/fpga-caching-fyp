/*
 * top level to call different modules in upstream
 compile with the following flags in icarus verilog:  -Wall -g2012 bc inputs/outputs fed back
 */ 

 `include "mem-model/shared/ramdownstream.sv"
 `include "mem-model/shared/ramupstream.sv"
 `include "upstream.sv"
 `include "SLT.sv"
//  `include "code/shared/rom_trade.mem"
 `define STATELOGC1 ((update_max == 1) && (check_risk == 1))
 `define STATELOGC2 ((update_max == 1) && (send_order == 1))
 `define STATELOGC3 ((check_risk== 1) && (send_order == 1))
 `define SAFETOTRADE  ($signed({1'b0, max_to_trade_reg[15:0]})> $signed(result))
 `define AMOUNTGOOD ((correct_amount == amount)||(correct_amount[31:16]== amount))

module upstream_processor_top(clk, client_id, amount, new_order, new_max, accumulated_orders, max_to_trade, done, cancelled_orders);
  input  clk, new_order, new_max; // for now use same clock to read and write, just not at same time
  input[4:0]  client_id;
  input[15:0] amount;
  output done;
  reg HRESETn;
  reg[31:0] correct_amount;
  reg pass_checks; //state machine input
  reg upstream_enable ; //RAM inputs
  reg counter; 
  
  cache_data_type mem_dataup_wr, mem_dataup, mem_datadown, mem_datadown_wr;
  cache_req_type mem_requp, mem_reqdown;

  reg       check_risk, send_order, update_max, done_rd, done_wr, done_reg; // state machine outputs
  input [15:0] cancelled_orders; // RAM data 
  reg [15:0] result, accumulated_orders_reg, cancelled_orders_reg ; // for signed comp 
  output [15:0] accumulated_orders;
  output[31:0] max_to_trade;
  reg [31:0] max_to_trade_reg ;
  reg memwr, nocare; // RAM bool output & State machine input, don't care about downstream
  assign done = done_reg;
  // // instantiate upstream ram 
  assign accumulated_orders =  accumulated_orders_reg ;
  assign max_to_trade =  max_to_trade_reg ;
  initial begin
    accumulated_orders_reg = '0;
    counter = '0;
  end

  // assign cancelled_orders = mem_datadown;

  dm_data_upstream RAMUPSTREAM(
    .clk(clk),    
    .data_req(mem_requp),    //CPU request input (CPU->cache)
    .data_write(mem_dataup_wr),     //memory response (memory->CPU)
    .data_read(mem_dataup) ,   //memory request (CPU->memory)
    .done_rd(done_rd),
    .done_wr(done_wr)
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
          
   
//  always @(posedge clk) begin: count_process // when clock signal gets high
//           counter= counter +1; // increase counter by 1
//     end : count_process


always @(client_id, amount) begin :  main_loop
  done_reg = '0;
  fork 
    begin : main_process
    // $display("start %0h", counter);  
    mem_requp.rdindex = client_id[9:0];   
    wait (done_rd === '0); //Implementation 1 
    $display("before read %0h", mem_dataup);  
    wait (done_rd === '1); //Implementation 1 
    $display("after read %0h", mem_dataup);  

    // $display("after read %0h", counter);  
    accumulated_orders_reg <= mem_dataup[15:0];
    cancelled_orders_reg <=  cancelled_orders;
    max_to_trade_reg <= mem_dataup >> 16;
    if ((new_max) && (amount>(mem_dataup[15:0])) ) // update max, shift amount 16 bits to left
      correct_amount <= amount << 16;
    else
      correct_amount <= amount[15:0];
    mem_dataup_wr <= correct_amount;
    result <= (accumulated_orders_reg+ (~cancelled_orders_reg+1) + amount );
    pass_checks <= $signed({1'b0, max_to_trade_reg[15:0]})>$signed(result); //extend for neg values
    // $display("before wrte %0h", counter);  
    mem_requp.we <= pass_checks; 
     if (pass_checks) begin
    wait (done_wr === '0); //Implementation 1 
    wait (done_wr === '1); //Implementation 1 
     end
    // $display("after wrte %0h", counter);  
  
  end : main_process


  // begin : wait_read
  //   if (done_rd == '0)
  //   wait (done_rd == '1); //Implementation 1 
  // end : wait_read


  // begin : wait_write
  //   if (done_wr == '0)
  //   wait (done_wr == '1); //Implementation 1 
  // end : wait_write
  
  // SVA to check if trade safe respected
  trade_pass_checks: assert property (
    @(client_id, amount) // throws an error if the trade is unsafe
    `SAFETOTRADE == pass_checks
      )
    else begin 
      $error ("pass_checks was not computer properly for client %0d; max to trade: %0d, accumulated amount: %0d, cancelled amount: %0d, pass_checks: %0d, amount %0d", client_id, max_to_trade, accumulated_orders, cancelled_orders, pass_checks, amount);
    end //

    // SVA to check if CORRECT amount written
    trade_correctamount_cpu: assert property (
      @(client_id, amount) // throws an error if the correct amount is different from amount to trade
      `AMOUNTGOOD == 1'b1
        )
      else begin 
        $error ("The amount was not indexed properly: amount %0d; correct amount (to write): %0d, correct_amount[31:16]: %0d, (correct_amount == amount) %0d , (correct_amount[31:16]== amount) %0d, ((correct_amount == amount)||(correct_amount[31:16]== amount))%0d", amount, correct_amount, correct_amount[31:16], (correct_amount == amount), (correct_amount[31:16]== amount), ((correct_amount == amount)||(correct_amount[31:16]== amount)));
      end // 
  
      
    // SVA to check if state logic 
    trade_state_logic1: assert property (
      @(posedge clk) // throws an error if two states high
      `STATELOGC1 == 1'b0
        )
      else begin 
        $error ("two states, update_max and check_risk, are simultaneously high");
      end //
        // SVA to check if state logic 
    trade_state_logic2: assert property (
      @(posedge clk) // throws an error if two states high
      `STATELOGC2 == 1'b0
        )
      else begin 
        $error ("two states, update_max and send_order, are simultaneously high");
      end //
        // SVA to check if state logic 
    trade_state_logic3: assert property (
      @(posedge clk) // throws an error if two states high
      `STATELOGC3 == 1'b0
        )
      else begin 
        $error ("two states, check_risk and send_order, are simultaneously high");
      end //

join
done_reg = '1;

end : main_loop

endmodule