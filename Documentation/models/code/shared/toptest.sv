// Testbench
module toptest;

  reg        clk, cpu_go, exchange_go, cpu_new_max;
  reg  [4:0] cpu_client_id, exchange_client_id;
  reg  [15:0] exchange_amount, cancelled_orders;
  reg [31:0] cpu_amount, accumulated_orders;
  
  // Instantiate design under test
  // D_WIDTH = 32
  // A_WIDTH = 5
  // A_MAX = 2^A_WIDTH = 524
  top  TOPMODULE (
    .clk(clk),
    .cpu_go(cpu_go),
    .exchange_go(exchange_go),
    .cpu_new_max(cpu_new_max),
    .cpu_client_id(cpu_client_id),
    .exchange_client_id(exchange_client_id),
    .exchange_amount(exchange_amount),
    .cancelled_orders(cancelled_orders),
    .accumulated_orders(accumulated_orders),
    .cpu_amount(cpu_amount));
    
  initial begin
    // Dump waves
    $dumpfile("../testbench/outputs/Module/topmodule.vcd");
    $dumpvars(1, toptest);
    
    clk = 0;
    cpu_go =0;
    exchange_go=0;
    cpu_new_max=1;
    cpu_client_id=5'h1B;
    exchange_client_id=5'h1B;
    exchange_amount=5'h2;
    cpu_amount=5'h3;

    $display("Read initial data.");
    toggle_clk;
    $display("Accumulated orders: %0h,  Cancelled orders: %0h", accumulated_orders, cancelled_orders);
    
    $display("Write new data to accumulated.");
    cpu_go =1;
    exchange_go=0;
    cpu_new_max=0;
    cpu_client_id=5'h1B;
    exchange_client_id=5'h1B;
    exchange_amount=5'h2;
    cpu_amount=5'h3;

    
    $display("Read new data.");
    toggle_clk;
    cpu_go =1;

    $display("Accumulated orders: %0h,  Cancelled orders: %0h", accumulated_orders, cancelled_orders);

    $display("Read initial data.");
    toggle_clk;
    $display("Accumulated orders: %0h,  Cancelled orders: %0h", accumulated_orders, cancelled_orders);
    
    $display("Write new data to accumulated.");
    cpu_go =1;
    exchange_go=0;
    cpu_new_max=0;
    cpu_client_id=5'h1B;
    exchange_client_id=5'h1B;
    exchange_amount=5'h2;
    cpu_amount=5'h3;
    $display("Write new data to max to trade.");
    cpu_go =0;
    exchange_go=0;
    cpu_new_max=0;
    cpu_client_id=0;
    exchange_client_id=5'h1B;
    exchange_amount=5'h2;
    cpu_amount=5'h3;

    
    $display("Read new data.");
    toggle_clk;
    $display("Accumulated orders: %0h,  Cancelled orders: %0h", accumulated_orders, cancelled_orders);


    $display("Write new data to accumulated.");
    clk = 0;
    cpu_go =0;
    exchange_go=1;
    cpu_new_max=0;
    cpu_client_id=0;
    exchange_client_id=5'h1B;
    exchange_amount=5'h2;
    cpu_amount=5'h3;

    
    $display("Read new data.");
    toggle_clk;
    $display("Accumulated orders: %0h,  Cancelled orders: %0h", accumulated_orders, cancelled_orders);
  end
  
  task toggle_clk;
    begin
      #10 clk = ~clk;
      #10 clk = ~clk;
    end
  endtask


endmodule