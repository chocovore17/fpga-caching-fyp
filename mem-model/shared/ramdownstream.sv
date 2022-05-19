/* 
 * Random Access Memory (RAM) with
 * 1 read port and 1 write port (for now )
 downstream_address_write = clientID 
 data_write = value of accumulated cancelled order (32 bits)
 */
 `include "mem-model/shared/cache_def.sv"
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
      $display("Loading downstream rom.");
      $readmemh("code/shared/rom_empty.mem", data_mem);
      // $displayb("%p", memory);
    end
    assign data_read = data_mem[data_req.rdindex];

    always @(posedge(clk)) begin

    if (data_req.we) begin
      if ((data_write+data_mem[data_req.wrindex])<16'hffaa) begin
        data_mem[data_req.wrindex] <= data_write+data_mem[data_req.wrindex];
        // repeat (4) @ (posedge clk);
      end
    end
    
      end
endmodule

