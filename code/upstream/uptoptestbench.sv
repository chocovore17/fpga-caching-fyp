// Testbench
module uptoptest;

  reg  clk, new_order, new_max, thenewmax;
  reg[4:0] client_id;
  reg[31:0] amount;
  wire[31:0] accumulated_orders,max_to_trade;
  // Instantiate device under test
  upstream_processor_top UPSTREAMPROCESSORTEST(.clk(clk),
          .client_id(client_id),
          .accumulated_orders(accumulated_orders),
          .amount(amount),
          .new_order(new_order),
          .max_to_trade(max_to_trade),
          .thenewmax(thenewmax),
          .new_max(new_max));
  
  initial begin
    // Dump waves
    $dumpfile("../testbench/outputs/Module/upstoptestbench.vcd");
    $dumpvars(1, uptoptest);
    //  initialise empty memory everywhere:
  
    clk = 0;
    amount = 32'h00000001;
    client_id = 5'h01;
    new_order = 0;
    new_max = 0;
    toggle_clk;

    $display("Read initial data.");
    $display("total orders for client : [%0h]: %0h,  %0h",
    client_id, accumulated_orders, new_order);
    $display("max orders for client : [%0h]: %0h,  %0h",
    client_id, max_to_trade, thenewmax);
    toggle_clk;

    $display("Write new data.");
    client_id = 5'h1B;
    amount = 32'h0000B0C5;
    new_max = 1;
    toggle_clk;
    new_max = 0;
    toggle_clk;
    $display("wait for state machine");
    $display("total orders for client : [%0h]: %0h,  %0h",
    client_id, accumulated_orders, new_order);
    $display("max orders for client : [%0h]: %0h,  %0h",
    client_id, max_to_trade, thenewmax);
    toggle_clk;
    
    $display("Write new data.");
    amount = 32'h000005C5;
    new_order = 1;
    toggle_clk;
    new_order = 0;
      
    $display("Read new data.");
    $display("total orders for client : [%0h]: %0h,  %0h",
    client_id, accumulated_orders, new_order);
    $display("max orders for client : [%0h]: %0h,  %0h",
    client_id, max_to_trade, thenewmax);
    toggle_clk;

    $display("Read new data.");
    $display("total orders for client : [%0h]: %0h,  %0h",
    client_id, accumulated_orders, new_order);
    $display("max orders for client : [%0h]: %0h,  %0h",
    client_id, max_to_trade, thenewmax);
      toggle_clk;

    $display("Read new data.");
    $display("total orders for client : [%0h]: %0h,  %0h",
    client_id, accumulated_orders, new_order);
    $display("max orders for client : [%0h]: %0h,  %0h",
    client_id, max_to_trade, thenewmax);
      toggle_clk;

    $display("Read new data.");
    $display("total orders for client : [%0h]: %0h,  %0h",
    client_id, accumulated_orders, new_order);
    $display("max orders for client : [%0h]: %0h,  %0h",
    client_id, max_to_trade, thenewmax);
  end
  
  task toggle_clk;
    begin
      #10 clk = ~clk;
      #10 clk = ~clk;
    end
  endtask
    
endmodule