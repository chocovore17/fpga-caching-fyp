/* 
 * Random Access Memory (RAM) with
 * 1 read port and 1 write port (for now )
 source: https://www.cypress.com/file/38101/download, http://web.mit.edu/6.111/www/f2017/handouts/L12.pdf 
 address_write = clientID 
 data_write = maximum allowed to trade (32 bits) if 'change_max' = true,  accumulated_orders = value of accumulated sent order (32 bits) otherwise
 */
module ram (clk_write, address_write,
  data_write, write_enable, change_max,
  clk_read, address_read, accumulated_orders, max_to_trade);
  parameter D_WIDTH = 64; // total length 
  parameter D1_WIDTH = 32; // max allowed to trade per client 
  parameter D2_WIDTH = 32; // Current accumulated orders 
  parameter A_WIDTH = 5;
  parameter A_MAX = 32; // 2^A_WIDTH

  // Write port
  input                clk_write;
  input                change_max; // flag to toggle changing the cache line - write to d1 or d2 
  input  [A_WIDTH-1:0] address_write;
  input  [D1_WIDTH-1:0] data_write;
  input                write_enable;

  // Read port
  input                clk_read;
  input  [A_WIDTH-1:0] address_read;
  output [D1_WIDTH-1:0] accumulated_orders;
  output [D1_WIDTH-1:0] max_to_trade;
  
  reg    [D1_WIDTH-1:0] accumulated_orders;
  reg    [D1_WIDTH-1:0] max_to_trade;

  // Memory as multi-dimensional array
  reg [D_WIDTH-1:0] memory [A_MAX-1:0];

  // Write data to memory
  always @(posedge clk_write) begin
    if (write_enable) and change_max begin
      memory[address_write + 32'h7FFFFFFF] <= data_write ; // if change max, update + 32 bits
    end 
    if (write_enable) and not change_max begin and data_write <= 8'h7FFFFFFF begin // check for overflow 
      memory[address_write] <= data_write; // if change max, RHS updated (indexed)
    end 
  end

  // Read data from memory
  always @(posedge clk_read) begin
    accumulated_orders <= memory[address_read];
    max_to_trade <= memory[address_read + 32'h7FFFFFFF];
  end

endmodule