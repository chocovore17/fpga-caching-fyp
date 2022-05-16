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
 parameter int TAGMAX = 32; //tag msb

module dm_data_upstream(clk,
  data_req,//data request/command, e.g. RW, valid
  data_write, //write port (128-bit line)
  data_read);
  input  clk;//, change_max;
  reg[4:0] i;

  input cache_req_type data_req;//data request/command, e.g. RW, valid
  input cache_data_type data_write; //write port (128-bit line)
  output cache_data_type data_read; //read port


  cache_data_type memory[0:TAGMAX];

  initial begin
      $display("Loading upstream cache.");
      $readmemh("code/shared/rom_trade.mem", memory);
      // $displayb("%p", memory);
    end
    assign data_read = memory[data_req.rdindex];
    always @(posedge(clk)) begin
      if (data_req.we)
      // $display("Writing %0h cache.", data_write);
      // $display("BEFORE %d, ",memory[data_req.rdindex]);
        if (data_write[31:16] > 2'b01) 
          memory[data_req.rdindex] <= {data_write[31:16],memory[data_req.rdindex][15:0] }; //+memory[data_req.index]; 
        else begin
          memory[data_req.rdindex][15:0] <=  memory[data_req.rdindex][15:0] + data_write[15:0]; //+memory[data_req.index];
        end
        // $display("AFTER %d, ",memory[data_req.rdindex]);
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


    /*cache: tag memory, single port, 1024 blocks*/
module dm_cache_tag_upstream(input bit clk, //write clock
  input cache_req_type tag_req, //tag request/command, e.g. RW, valid
  input cache_tag_type tag_write,//write port
  output cache_tag_type tag_read //read port);//read port
);
  // timeunit 1ns; timeprecision 1ps;
  cache_tag_type tag_mem[0:TAGMAX];
  initial begin
  for (int i=0; i<TAGMAX; i++)
  tag_mem[i] = '0;
  end
  
  // initial begin
  //   $display("Loading upstream cache.");
  //   $readmemh("code/shared/rom_trade.mem", tag_mem);
  //   // $displayb("%p", memory);
  // end
  

  assign tag_read = tag_mem[tag_req.rdindex];
  always @(posedge(clk)) begin

  if (tag_req.we)  begin
  // $display("tag_write value %0h., tag_req.rdindex %0h", tag_write.tag, tag_req.rdindex);
    tag_mem[tag_req.rdindex] <= tag_write;
      // $displayb("%p", tag_mem);
  end

  end
endmodule



module mem_controller(input bit clk, //write clock
  output mem_data_type mem_data, //memory response (memory->cache)
  // input change_max,
  input mem_req_type mem_req) ;//memory request (cache->memory))
    reg[4:0] i;
    reg[127:0] datav;
    cache_data_type memory[0:121];
    assign mem_data.data = datav;
    initial begin
        $display("Loading upstream memory.");
        $readmemh("code/shared/rom_trade.mem", memory);
        // $displayb("%p", memory);
      end
      always @(mem_req.addr) begin
        datav = memory[mem_req.addr];
        // $displayb("DATAV %0h", datav);
        for (i=0; i<5; i=i+1)begin
              @(posedge clk) ; 
            end
            wait (i=== 5); //Implementation 1      
      end 
      assign mem_data.ready = 1'b1;
  
      always @(mem_req.rw) begin
        // if (mem_req.rw) begin
          $display("Writing %0h mem.", mem_req.data);
          if (mem_req.data[31:16] > 2'b01) 
            memory[mem_req.addr] <= {mem_req.data[31:15],memory[mem_req.addr][15:0] }; //+memory[data_req.index]; 
          else begin
            memory[mem_req.addr][15:0] <=  memory[mem_req.addr][15:0] + mem_req.data[15:0]; //+memory[data_req.index];
          end
             $displayb("MEMORY %p", memory[mem_req.addr]);
          for (i=0; i<7; i=i+1)
             @(posedge clk) ; 
        wait (i=== 7); //Implementation 1   
        // end   
        end
      // // SVA to check if gpio_out during reset
      //     trade_risk_check_mem: assert property (
      //       @(posedge clk) // throws an error if the trade is unsafe
      //         `MAX_DEF == 1'b1
      //         )
      //       else begin 
      //         $error ("The max to trade not def for client %0h; max to trade: %0h, accumulated amount: %0h", data_req.rdindex, memory[data_req.rdindex][31:16], memory[data_req.rdindex][15:0]);
      //         $displayb(" %0d,  %p",data_write, memory[data_req.rdindex]);
      //       end //
  endmodule

  

/*cache finite state machine*/
module dm_cache_fsm_upstream(input bit clk, input bit rst,
  input cpu_req_type cpu_req, //CPU request input (CPU->cache)
  input mem_data_type mem_data, //memory response (memory->cache)
  // input change_max,
  output mem_req_type mem_req, //memory request (cache->memory)
  output cpu_result_type cpu_res //cache result (cache->CPU)
  );
  /*write clock*/
  typedef enum {idle, compare_tag, allocate, write_back} cache_state_type;
  /*FSM state register*/
  cache_state_type vstate, rstate;
  /*interface signals to tag memory*/
  cache_tag_type tag_read; //tag read result
  cache_tag_type tag_write; //tag write data
  cache_req_type tag_req; //tag request
  /*interface signals to cache data memory*/
  cache_data_type data_read; //cache line read data
  cache_data_type data_write; //cache line write data
  cache_req_type data_req; //data req
   /*temporary variable for cache controller result*/
  cpu_result_type v_cpu_res;
  /*temporary variable for memory controller request*/
  mem_req_type v_mem_req;
  assign mem_req = v_mem_req; //connect to output ports
  assign cpu_res = v_cpu_res; 
  always_comb begin
    // $display("vstate : %0d", vstate);

  /*-------------------------default values for all signals------------*/
  /*no state change by default*/
  vstate = rstate;
  v_cpu_res = '{0, 0}; tag_write = '{0, 0, 0};
  /*read tag by default*/
  tag_req.we = '0;
  /*direct map index for tag*/
  tag_req.rdindex = cpu_req.rdindex[13:4];
 
  /*read current cache line by default*/
  data_req.we = '0;
  /*direct map index for cache data*/
  data_req.rdindex = cpu_req.rdindex[13:4];
  /*modify correct word (32-bit) based on address*/
  data_write = data_read;
  case(cpu_req.rdindex[3:2])
  2'b00:data_write[31:0] = cpu_req.data;
  2'b01:data_write[63:32] = cpu_req.data;
  2'b10:data_write[95:64] = cpu_req.data;
  2'b11:data_write[127:96] = cpu_req.data;
 endcase
 
  /*read out correct word(32-bit) from cache (to CPU)*/
 $display("cpu_req.rdindex[3:2] : %0h", cpu_req.rdindex[3:2]);
  case(cpu_req.rdindex[3:2])
  2'b00:v_cpu_res.data = data_read[31:0];
  2'b01:v_cpu_res.data = data_read[63:32];
  2'b10:v_cpu_res.data = data_read[95:64];
  2'b11:v_cpu_res.data = data_read[127:96];
  endcase
 
  /*memory request address (sampled from CPU request)*/
  v_mem_req.addr = cpu_req.rdindex;
  /*memory request data (used in write)*/
  v_mem_req.data = data_read;
   v_mem_req.rw = '0;
 
 
  //------------------------------------Cache FSM-------------------------
  case(rstate)
  /*idle state*/
  idle : begin
  /*If there is a CPU request, then compare cache tag*/
  if (cpu_req.valid)
  vstate = compare_tag;
  end
  /*compare_tag state*/
  compare_tag : begin
    // $display("/*compare_tag state*/");

  /*cache hit (tag match and cache entry is valid)*/
  if (cpu_req.rdindex[TAGMSB:TAGLSB] == tag_read.tag && tag_read.valid) begin
  v_cpu_res.ready = '1;
  // $display("data cpu %d, ", cpu_res.data);

  /*write hit*/
  if (cpu_req.rw) begin
  /*read/modify cache line*/
    
  tag_req.we = '1; data_req.we = 1'b1;
  /*no change in tag*/
  tag_write.tag = tag_read.tag;
  // $display("data_req.we; %d, ", data_req.we);
  tag_write.valid = '1;
  /*cache line is dirty*/
  tag_write.dirty = '1;
  end
 
  /*xaction is finished*/
  vstate = idle;
  end
  /*cache miss*/
  else begin
  /*generate new tag*/
  tag_req.we = '1;
  tag_write.valid = '1;
  /*new tag*/
  tag_write.tag = cpu_req.rdindex[TAGMSB:TAGLSB];
  /*cache line is dirty if write*/
  tag_write.dirty = cpu_req.rw;
 
  /*generate memory request on miss*/
  v_mem_req.valid = '1;
  /*compulsory miss or miss with clean block*/
  if (tag_read.valid == 1'b0 || tag_read.dirty == 1'b0)
  /*wait till a new block is allocated*/
  vstate = allocate;
  else begin
  /*miss with dirty line*/
  /*write back address*/
  v_mem_req.addr = {tag_read.tag, cpu_req.rdindex[TAGLSB-1:0]};
  v_mem_req.rw = '1;
  /*wait till write is completed*/
  vstate = write_back;
  end
  end
  end
  /*wait for allocating a new cache line*/
  allocate: begin
  /*memory controller has responded*/
    // $display("mem data : %0d, mem data rdy: %0d", mem_data.data, mem_data.ready);
  if (mem_data.ready) begin
  /*re-compare tag for write miss (need modify correct word)*/
  vstate = compare_tag;
  data_write = mem_data.data;
  /*update cache line data*/
  data_req.we = '1;
  end
  end
  /*wait for writing back dirty cache line*/
  write_back : begin
  /*write back is completed*/
  if (mem_data.ready) begin
  /*issue new memory request (allocating a new line)*/
  v_mem_req.valid = '1;
  v_mem_req.rw = '0;
 
  vstate = allocate; 
  end
  end
  endcase
 end
 always_ff @(posedge(clk)) begin
  // $display(mem_data.data);
  if (rst)
  rstate <= idle; //reset to idle state
  else
  rstate <= vstate;
 end
 /*connect cache tag/data memory*/
 dm_cache_tag_upstream ctag(.*);
 dm_data_upstream cdata(.*);
 mem_controller cmem(.*);
 endmodule