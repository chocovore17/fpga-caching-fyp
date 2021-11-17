// Testbench
module downtoptesttest;
  reg clk, memwr, downenable;
  reg[4:0] client_id;
  reg[31:0] amount;
  wire[31:0] cancelled_orders;
  

  // instantiate downstream ram (should it be done here? )
  // ramdownstream #(32, 5, 32) RAMDOWNSTREAM (
  //   .clk_write(clk),                            // input 
  //   .downstream_address_write(client_id),       // input 
  //   .data_write(amount),       // input[31:0]  // check that it doesn't mix for client with pipeline 
  //   .downstream_write_enable(downenable),// input 
  //   .clk_read(clk),                             // input 
  //   .address_read(client_id),                   // input [4:0]
  //   .memwr(memwr),                              // output 
  //   .data_read(amount));              // output[31:0]

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