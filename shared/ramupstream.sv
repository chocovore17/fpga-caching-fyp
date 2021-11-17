/* 
 * Random Access Memory (RAM) with
 * 1 read port and 1 write port (for now )
 source: https://www.cypress.com/file/38101/download, http://web.mit.edu/6.111/www/f2017/handouts/L12.pdf 
 address_write = clientID 
 data_write = maximum allowed to trade (32 bits) if 'change_max' = true,  accumulated_orders = value of accumulated sent order (32 bits) otherwise
 */
module ramupstream (clk_write, address_write,
  data_write, write_enable, change_max,
  clk_read, address_read, accumulated_orders, max_to_trade, memwr);
  parameter D_WIDTH = 32; // max allowed to trade per client (first 32) // Current accumulated orders (last 32)
  parameter A_WIDTH = 10;
  parameter A_MAX = 1024; // 2^A_WIDTH

  // Write port
  input                clk_write;
  input                change_max; // flag to toggle changing the cache line - write to d1 or d2 
  input  [A_WIDTH-1:0] address_write;
  input  [D_WIDTH-1:0] data_write;
  input                write_enable;

  // Read port
  input                clk_read;
  input  [A_WIDTH-1:0] address_read;
  output [D_WIDTH-1:0] accumulated_orders;
  output [D_WIDTH-1:0] max_to_trade;
  output              memwr;
  
  reg    [D_WIDTH-1:0] accumulated_orders;
  reg    [D_WIDTH-1:0] max_to_trade;
  reg                  memwr;

  // Memory as multi-dimensional array
  reg [D_WIDTH-1:0] memory [A_MAX-1:0];

  // initialise memory
  integer i;
  initial begin
    for (i=0;i<A_MAX;i=i+1)
      memory[i] = 32'b0;
  end

  // Write data to memory
  always @(posedge clk_write) begin
    memwr<=1'b0;
    if (write_enable) begin
      if(change_max) begin
        memory[address_write + 10'b1111100000] <= data_write ; // if change max, update + 32 bits
        memwr <= 1'b1;
      end
      else begin// check for overflow 
        memory[address_write] <= data_write; // if change max, RHS updated (indexed)
        memwr <= 1'b1;
      end 
    end
  end

  // Read data from memory
  always @(posedge clk_read) begin
    accumulated_orders <= memory[address_read];
    max_to_trade <= memory[address_read + 10'b1111100000];
  end

endmodule