 /*
Random access Memory (RAM) with
1 read
port and 1 write
port (for now)
source : https : //www.cypress.com/file/38101/upload, http : //web.mit.edu/6.111/www/f2017/handouts/L12.pdf
address_write = clientID
data_write = maximum allowed to trade (32 bits) if 'change_max' = true, accumulated_orders = value of accumulated sent order (32 bits) otherwise
*/

`include "mem_model_bs/shared/cache_def.sv"

import cache_def::* ;
`define MAX_DEF ((data_read >> 16) >= 0)
parameter int TAGMAX = 2; //tag msb

// cache finite state machine

module dm_mem_upstream(input bit clk, input bit rst, 
	input cpu_req_type cpu_req, //CPU request input (CPU -> cache)
	input change_max, 
	output cpu_result_type cpu_res, //cache result (cache -> CPU)
	output written
	);
	reg[4 : 0] i;
	reg written_reg;
	assign written = written_reg;
	cache_data_type memory[0 : 121];

	initial begin
    $display("Loading upstream memory.");
    $readmemh("mem_model_bs/shared/rom_trade.mem", memory);
    // $displayb("%p", memory);
  end

  always @(cpu_req.rdindex) begin
    cpu_res.ready = 1'b0; 
    cpu_res.data = memory[cpu_req.rdindex];
    fork
      begin
        for (i = 0; i < 4; i = i + 1)begin
            @(posedge clk);
        end
      end
    join
    wait fork;
    cpu_res.ready = 1'b1;
  end
  // assign mem_data.ready = 1'b1;

  always @(cpu_req.rw) begin
    written_reg = 1'b0;
    if (cpu_req.rw) begin
      if (cpu_req.data[31 : 16] > 2'b01)
        memory[cpu_req.rdindex] = {cpu_req.data[31 : 15], memory[cpu_req.rdindex][15 : 0] }; // + memory[data_req.index];
      else
        begin
          memory[cpu_req.rdindex][15 : 0] = memory[cpu_req.rdindex][15 : 0] + cpu_req.data[15 : 0]; // + memory[data_req.index];
        end
        fork
          begin  : wait_fork
            for (i = 0;i < 3;  i = i + 1) begin
              @(posedge clk);
              // $display("watng fork, %0h", i);
            end
          end : wait_fork
        join
        wait fork;
        written_reg = 1'b1;
        // $display("HEYYYYY Writing %0h mem. after wait, written_reg", cpu_req.data, written_reg);

    end
  end
 endmodule