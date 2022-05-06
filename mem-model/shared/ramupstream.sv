/* 
 * Random Access Memory (RAM) with
 * 1 read port and 1 write port (for now )
 source: https://www.cypress.com/file/38101/upload, http://web.mit.edu/6.111/www/f2017/handouts/L12.pdf 
 address_write = clientID 
 data_write = maximum allowed to trade (32 bits) if 'change_max' = true,  accumulated_orders = value of accumulated sent order (32 bits) otherwise
 */

 `include "code/shared/cache_def.sv"

 import cache_def::*;
 `define MAX_DEF ((data_read>>16) >= 0) 

module dm_data_upstream(clk,
  data_req,//data request/command, e.g. RW, valid
  data_write, //write port (128-bit line)
  data_read);
  input  clk;//, change_max;
  input cache_req_type data_req;//data request/command, e.g. RW, valid
  input cache_data_type data_write; //write port (128-bit line)
  output cache_data_type data_read; //read port
  
  
  reg[4:0] i;
  reg[31:0] datav;  
  assign data_read = memory[data_req.rdindex];
  cache_data_type memory[0:512];

  initial begin
      $display("Loading upstream rom.");
      $readmemh("code/shared/rom_trade.mem", memory);
      // $displayb("%p", memory);
    end

    
    always @(data_req.rdindex) begin
      datav = memory[data_req.rdindex];
      for (i=0; i<4; i=i+1)
            @(posedge clk) ; 
            $display("Read wait.");

    end 
    // assign data_read = memory[data_req.rdindex];


    always @(posedge(clk)) begin
      if (data_req.we)
        if (data_write[31:16] > 2'b01) 
          memory[data_req.rdindex] <= {data_write[31:15],memory[data_req.rdindex][15:0] }; //+memory[data_req.index]; 
        else begin
          memory[data_req.rdindex][15:0] <=  memory[data_req.rdindex][15:0] + data_write[15:0]; //+memory[data_req.index];
        end 
        for (i=0; i<6; i=i+1)
          @(posedge clk) ; 
        $display("Write wait.");
   end
    // SVA to check if gpio_out during reset
        trade_risk_check_mem: assert property (
          @(posedge clk) // throws an error if the trade is unsafe
            `MAX_DEF == 1'b1
            )
          else begin 
            $error ("The max to trade not def for client %0h; max to trade: %0h, accumulated amount: %0h", data_req.rdindex, memory[data_req.rdindex][31:16], memory[data_req.rdindex][15:0]);
            $displayb(" %0d,  %p",data_write, memory[data_req.rdindex]);
          end //
endmodule

