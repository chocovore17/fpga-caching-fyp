// Testbench
module downtoptesttest;
  reg clk, memwr, downenable;
  reg[4:0] client_id;
  reg[31:0] amount;
  wire[31:0] cancelled_orders;
  

  // Instantiate device under test
  downstream_top DOWNSTREAMTOP(
          .clk(clk),
          .memwr(memwr),
          .client_id(client_id),
          .amount(amount),
          .cancelled_orders(cancelled_orders));
  
  initial begin
    // Dump waves
    $dumpfile("../testbench/outputs/Module/downstreamtop.vcd");
    $dumpvars(1, downtoptesttest);

    //  initialise empty memory everywhere:
  
    clk = 0;
    amount = 32'h00000001;
    client_id = 5'h01;
    toggle_clk;

    $display("Read initial data.");
    $display("cancelled orders for client : [%0h]: %0h,  %0h",
    client_id, cancelled_orders, memwr);
    toggle_clk;

    $display("Write new data.");
    client_id = 5'h1B;
    amount = 32'h000000C5;
    toggle_clk;
    toggle_clk;
    $display("wait for state machine");
    $display("cancelled orders for client : [%0h]: %0h,  %0h",
      client_id, cancelled_orders, memwr);
    toggle_clk;
    
    $display("Write new data.");
    amount = 32'h000005C5;
    toggle_clk;
      
    $display("Read new data.");
    $display("cancelled orders for client : [%0h]: %0h,  %0h",
      client_id, cancelled_orders, memwr);
    toggle_clk;

    $display("Read new data.");
    $display("cancelled orders for client : [%0h]: %0h,  %0h",
      client_id, cancelled_orders, memwr);
      toggle_clk;

    $display("Read new data.");
    $display("cancelled orders for client : [%0h]: %0h,  %0h",
      client_id, cancelled_orders, memwr);
      toggle_clk;

    $display("Read new data.");
    $display("cancelled orders for client : [%0h]: %0h,  %0h",
      client_id, cancelled_orders, memwr);
  end
  
  task toggle_clk;
    begin
      #10 clk = ~clk;
      #10 clk = ~clk;
    end
  endtask
    
endmodule