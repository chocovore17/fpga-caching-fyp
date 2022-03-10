// Testbench
module test;

  reg        clk_write;
  reg  [4:0] downstream_address_write;
  reg  [31:0] data_write;
  reg        downstream_write_enable;
  reg        clk_read;
  reg  [4:0] address_read;
  wire [31:0] data_read;
  
  // Instantiate design under test
  // D_WIDTH = 32
  // A_WIDTH = 5
  // A_MAX = 2^A_WIDTH = 32
  ramdownstream #(32, 5, 32) RAM (
    .clk_write(clk_write),
    .downstream_address_write(downstream_address_write),
    .data_write(data_write),
    .downstream_write_enable(downstream_write_enable),
    .clk_read(clk_read),
    .address_read(address_read),
    .data_read(data_read));
    
  initial begin
    // Dump waves
    $dumpfile("../testbench/outputs/Module/ramtestbenchdump.vcd");
    $dumpvars(1, test);
    
    clk_write = 0;
    clk_read = 0;
    downstream_write_enable = 0;
    address_read = 5'h1B;
    downstream_address_write = address_read;

    $display("Read initial data.");
    toggle_clk_read;
    $display("data[%0h]: %0h",
      address_read, data_read);
    
    $display("Write new data.");
    downstream_write_enable = 1;
    data_write = 32'h000000C5;
    toggle_clk_write;
    downstream_write_enable = 0;
    
    $display("Read new data.");
    toggle_clk_read;
    $display("data[%0h]: %0h",
      address_read, data_read);
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