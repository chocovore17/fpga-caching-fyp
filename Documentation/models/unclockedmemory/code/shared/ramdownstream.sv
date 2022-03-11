/* 
 * Random Access Memory (RAM) with
 * 1 read port and 1 write port (for now )
 downstream_address_write = clientID 
 data_write = value of accumulated cancelled order (32 bits)
 */
 `include "code/shared/cache_def.sv"
 import cache_def::*;

module dm_data_downstream(clk,
  data_req,//data request/command, e.g. RW, valid
  data_write, //write port (128-bit line)
   data_read); //read port
  input  clk;
  input cache_req_type data_req;//data request/command, e.g. RW, valid
  input cache_data_type data_write; //write port (128-bit line)
  output cache_data_type data_read; //read port
  cache_data_type data_mem[0:1023];

  initial begin
    for (int i=0; i<1024; i++)
    data_mem[i] = '0;
    end
    assign data_read = data_mem[data_req.index];
    always @(posedge(clk)) begin
    if (data_req.we)
    data_mem[data_req.index] <= data_write+data_mem[data_req.index];
    end
endmodule
