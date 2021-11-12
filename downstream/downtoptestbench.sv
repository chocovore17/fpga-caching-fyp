// Testbench
 `include "downstream_top.sv"

module downtoptesttest;

  reg  clk, ack;
  reg[4:0] client_id;
  reg[31:0] amount;
  wire[31:0] cancelled_orders, total_cancel;
  
  // Instantiate device under test
  downstream_top DOWNSTREAMTOP(.clk(clk),
          .ack(ack),
          .client_id(client_id),
          .amount(amount),
          .total_cancel(total_cancel),
          .cancelled_orders(cancelled_orders));
  
  initial begin
    // Dump waves
    $dumpfile("../testbench/outputs/Module/downstreamtop.vcd");
    $dumpvars(1, downtoptesttest);
    ack = 1'b0;
    client_id = 5'h1B;

    $display("Read initial data.");
    toggle_clk;
    $display("cancelled orders for client : [%0h]: %0h",
      client_id, total_cancel);
    
    $display("Write new data.");
    ack = 1'b1;
    amount = 32'h000000C5;
    toggle_clk;
    
    ack = 1'b1;
    $display("Read new data.");
    toggle_clk;
    $display("cancelled orders for client : [%0h]: %0h",
      client_id, total_cancel);
    
    $display("Write new data.");
    ack = 1'b1;
    amount = 32'h000000C5;
    toggle_clk;
    ack = 1'b0;
      
    $display("Read new data.");
    toggle_clk;
    $display("cancelled orders for client : [%0h]: %0h",
      client_id, total_cancel);
    
  end
  
  
  task toggle_clk;
    begin
      #10 clk = ~clk;
      #10 clk = ~clk;
    end
  endtask
  
endmodule