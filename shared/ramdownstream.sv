/* 
 * Random Access Memory (RAM) with
 * 1 read port and 1 write port (for now )
 downstream_address_write = clientID 
 data_write = value of accumulated cancelled order (32 bits)
 */
module ramdownstream (clk_write, downstream_address_write,
  data_write, downstream_write_enable,
  clk_read, address_read, data_read, memwr);
  
  parameter D_WIDTH = 32;
  parameter A_WIDTH = 5;
  parameter A_MAX = 32; // 2^A_WIDTH

  // Write port
  input                clk_write;
  input  [A_WIDTH-1:0] downstream_address_write;
  input  [D_WIDTH-1:0] data_write;
  input                downstream_write_enable;

  // Read port
  input                clk_read;
  input  [A_WIDTH-1:0] address_read;
  output [D_WIDTH-1:0] data_read;
  output               memwr; //ensures it's written
  
  reg                 memwr;
  reg    [D_WIDTH-1:0] data_read;
  
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
    if (downstream_write_enable==1'b1) begin
      memory[downstream_address_write] <= data_write;
      memwr <= 1'b1;
    end
    else begin 
          memwr<=1'b0;
    end 
  end

  // Read data from memory
  always @(posedge clk_read) begin
    data_read <= memory[address_read];
  end

endmodule