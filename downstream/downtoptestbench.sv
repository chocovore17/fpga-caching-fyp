// Testbench
module downtoptesttest;

  reg  ack;
  reg[4:0] client_id;
  reg[31:0] amount;
  wire[31:0] cancelled_orders;
  
  // Instantiate device under test
  downstream_top DOWNSTREAMTOP(
          .ack(ack),
          .client_id(client_id),
          .amount(amount),
          // .total_cancel(total_cancel),
          .cancelled_orders(cancelled_orders));
  
  initial begin
    // Dump waves
    $dumpfile("../testbench/outputs/Module/downstreamtop.vcd");
    $dumpvars(1, downtoptesttest);
    ack = 1'b0;
    client_id = 5'h1B;

    $display("Read initial data.");
    $display("cancelled orders for client : [%0h]: %0h",
      client_id, cancelled_orders);
    
    $display("Write new data.");
    ack = 1'b1;
    amount = 32'h000000C5;
    
    $display("Read new data.");
    $display("cancelled orders for client : [%0h]: %0h",
      client_id, cancelled_orders);
    
    $display("Write new data.");
    ack = 1'b1;
    amount = 32'h000000C5;
    ack = 1'b0;
      
    $display("Read new data.");
    $display("cancelled orders for client : [%0h]: %0h",
      client_id, cancelled_orders);
    
  end
  
    
endmodule