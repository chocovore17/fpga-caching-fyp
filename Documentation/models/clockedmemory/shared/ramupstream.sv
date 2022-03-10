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
  parameter A_WIDTH = 5;
  parameter A_MAX = 32; // 2^A_WIDTH

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
  reg    [D_WIDTH-1:0] accumulated_read;
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
        // UPDATE 16 MSB
        // read 16 LSB for current max and shift max 16bits to left 
        //  mem value = new max << 16 + existing mem && (16 bit lsb filte
        memory[address_write][31:16] <= data_write;// if change max, update + 32 bits
        memwr <= 1'b1;
      end
      else begin// check for overflow 
        // UPDATE 16 LSB 
        memory[address_write][15:0] <= data_write[15:0]; // + memory[address_write][15:0]; // if change max, RHS updated (indexed)
        memwr <= 1'b1;
      end 
    end
  end

  // Read data from memory
  // always @(posedge clk_read) begin
  assign accumulated_orders = memory[address_read][15:0]; // LSB
  assign max_to_trade = memory[address_read][31:16]; // MSB
  // end

endmodule