// Testbench
module test;

  reg        clk_write;
  reg        change_max;
  reg  [4:0] address_write;
  reg  [31:0] data_write;
  reg        write_enable;
  reg        clk_read;
  reg  [4:0] address_read;
  wire [31:0] accumulated_orders;
  wire [31:0] max_to_trade;
  
  // Instantiate design under test
  // D_WIDTH = 32
  // A_WIDTH = 5
  // A_MAX = 2^A_WIDTH = 524
  ramupstream #(32, 5, 32) RAMUPSTREAM (
    .clk_write(clk_write),
    .change_max(change_max),
    .address_write(address_write),
    .data_write(data_write),
    .write_enable(write_enable),
    .clk_read(clk_read),
    .address_read(address_read),
    .accumulated_orders(accumulated_orders),
    .max_to_trade(max_to_trade));
    
  initial begin
    // Dump waves
    $dumpfile("../testbench/outputs/Module/ramupstreamdump.vcd");
    $dumpvars(1, test);
    
    clk_write = 0;
    clk_read = 0;
    write_enable = 0;
    change_max = 0;
    address_read = 5'h1B;
    address_write = address_read;

    $display("Read initial data.");
    toggle_clk_read;
    $display("data[%0h]: %0h, %0h",
      address_read, accumulated_orders, max_to_trade);
    
    $display("Write new data to accumulated.");
    write_enable = 1;
    data_write = 32'h08;
    toggle_clk_write;
    write_enable = 0;
    
    $display("Read new data.");
    toggle_clk_read;
    $display("data[%0h]: %0h, %0h",
      address_read, accumulated_orders, max_to_trade);

    $display("Write new data to max to trade.");
    write_enable = 1;
    change_max = 1;
    data_write = 32'h05A3;
    toggle_clk_write;
    write_enable = 0;
    change_max = 0;
    
    $display("Read new data.");
    toggle_clk_read;
    $display("data[%0h]: %0h, %0h",
      address_read, accumulated_orders,max_to_trade);


    $display("Write new data to accumulated.");
    write_enable = 1;
    data_write = 32'h03;
    toggle_clk_write;
    write_enable = 0;
    
    $display("Read new data.");
    toggle_clk_read;
    $display("data[%0h]: %0h, %0h",
      address_read, accumulated_orders, max_to_trade);
  end
  
  task toggle_clk_write;
    begin
      #10 clk_write = ~clk_write;
      #10 clk_write = ~clk_write;
    end
  endtask

  task toggle_clk_read;
    begin
      #10 clk_read = ~clk_read;
      #10 clk_read = ~clk_read;
    end
  endtask

endmodule