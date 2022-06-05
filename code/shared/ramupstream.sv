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
 parameter int TAGMAX = 16; //tag msb 1 for memory model 

module dm_data_upstream(clk,
  data_req,//data request/command, e.g. RW, valid
  data_write, //write port (128-bit line)
  data_read);
  input  clk;//, change_max;
  reg[4:0] i;
  reg[12:0] totalsent =0;
  reg[12:0] totalacc =0;

  input cache_req_type 
  data_req;//data request/command, e.g. RW, valid
  input cache_data_type data_write; //write port (128-bit line)
  output cache_data_type data_read; //read port
  reg[31:0] data_writeprev =0;

  cache_data_type memory[0:TAGMAX];

  initial begin
      $display("Loading upstream cache.");
      $readmemh("code/shared/rom_trade.mem", memory);

      // $displayb("%p", memory);
    end
    assign data_read = memory[data_req.rdindex];
    // always @(posedge(clk)) begin
    always_comb begin
      if ((data_req.we)&&(data_write != data_writeprev)) begin
      totalsent <=  totalsent+1;
      $display("\n=============\n\ntotalsent to cache %0d, data_write %0h.", totalsent, data_write);
        if (data_write[31:16] > 2'b01) 
          memory[data_req.rdindex] <= {data_write[31:16],memory[data_req.rdindex][15:0] }; //+memory[data_req.index]; 
        else begin
          totalacc <=  totalacc+1;
          memory[data_req.rdindex][15:0] <=  memory[data_req.rdindex][15:0] + data_write[15:0]; //+memory[data_req.index];
          $display("totalsent to accuorders cache %0d, data_write %0h.", totalacc, data_write);
        end
        data_writeprev =data_write;
      end
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
  reg tagvdirty;
  reg[6:0] i;
  initial begin
    for (int i=0; i<TAGMAX; i++)
      tag_mem[i] = '0;
  end
  

  assign tag_read.tag = tag_mem[tag_req.rdindex];
  assign tag_read.valid = 1'b1;
  // assign tag_write.valid = 1'b1; //could add more fancy check later

  always @(posedge(clk)) begin
    // $displayb("%p", tag_mem);
    if (tag_req.we)  begin
      // $display("\n\n\n\n\n writing tag_write %0h in tag cache at index %0h ", tag_write.tag, tag_req.rdindex);
      tag_mem[tag_req.rdindex] = tag_write;
      if (tag_write.dirty)  begin
        fork
          begin  : dirty_wait_fork
            for (i = 0;i < 3;  i = i + 1) begin
              @(posedge clk);
              // $display("WAITS TAG");
            end
          end : dirty_wait_fork
        join
        wait fork;
      end
    end
    // $display("tag mem is now %p", tag_mem);

  end

endmodule



module mem_controller(input bit clk, //write clock
  output mem_data_type mem_data, //memory response (memory->cache)
  // input change_max,
  input mem_req_type mem_req) ;//memory request (cache->memory))
    reg[4:0] i;
    reg[127:0] datav;
    reg datardy;
    cache_data_type memory[0:121];
    assign mem_data.data = datav;
    assign mem_data.ready = datardy;
    // assign mem_req.valid = mem_req_valid;

    initial begin
        $display("Loading upstream memory.");
        $readmemh("code/shared/rom_trade.mem", memory);
        // $displayb("%p", memory);
      end
      always @(mem_req.addr) begin
        // datardy = 1'b0;
        datav = memory[mem_req.addr];
        // $displayb("DATAV %0h", datav);
        // for (i=0; i<6; i=i+1)begin
        //       @(posedge clk) ; 
        //     end
        //     wait (i=== 5); //Implementation 1    
            // datardy = 1'b1;
      end 
      // assign mem_data.ready = 1'b1;
  
      always @(mem_req.rw, mem_req.valid) begin
        // if (mem_req.rw) begin
        datardy = 1'b0;

          // $display("Writing %0d mem.", mem_req.data);
          if (mem_req.data[31:16] > 2'b01) 
            memory[mem_req.addr] <= {mem_req.data[31:15],memory[mem_req.addr][15:0] }; //+memory[data_req.index]; 
          else begin
            memory[mem_req.addr][15:0] <=  memory[mem_req.addr][15:0] + mem_req.data[15:0]; //+memory[data_req.index];
          end  
             fork
              begin  : write_wait_fork
                for (i = 0;i < 4;  i = i + 1) begin
                  @(posedge clk);
                  // $display(" WAITS MEM");
                end
              end : write_wait_fork
            join
            wait fork;
            datardy = 1'b1;
            // mem_req_valid = 1'b0;
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
    
    /*-------------------------default values for all signals------------*/
    /*no state change by default*/
    vstate = rstate;
    v_cpu_res = '{0, 0}; tag_write = '{0, 0, 0};
    /*read tag by default*/
    tag_req.we = '0;
    /*direct map index for tag*/
    // IT FIXED IT!
    tag_req.rdindex = (cpu_req.rdindex[13:4] % TAGMAX);
  
    /*read current cache line by default*/
    data_req.we = '0;
    /*direct map index for cache data*/
    data_req.rdindex = cpu_req.rdindex[13:4];
    /*modify correct word (32-bit) based on address*/
    // data_write = data_read[32:0];
    data_write = cpu_req.data;
    case(cpu_req.rdindex[3:2])
    2'b00:data_write[31:0] = cpu_req.data;
    // 2'b01:data_write[63:32] = cpu_req.data;
    // 2'b10:data_write[95:64] = cpu_req.data;
    // 2'b11:data_write[127:96] = cpu_req.data; //no need for now
  endcase
  
    /*read out correct word(32-bit) from cache (to CPU)*/
    case(cpu_req.rdindex[3:2])
    2'b00:v_cpu_res.data = data_read[31:0];
    // 2'b01:v_cpu_res.data = data_read[63:32];
    // 2'b10:v_cpu_res.data = data_read[95:64];
    // 2'b11:v_cpu_res.data = data_read[127:96];
    endcase
  
    /*memory request address (sampled from CPU request)*/
    v_mem_req.addr = cpu_req.rdindex;
    /*memory request data (used in write)*/
    v_mem_req.data = data_write;
    v_mem_req.rw = '0;
    // $display("state, %0h, mem_data.ready %0b, mem_req.rw %0b, mem_req.valid %0b", rstate, mem_data.ready, mem_req.rw, mem_req.valid);

    //------------------------------------Cache FSM-------------------------
    case(rstate)
      /*idle state*/
      idle : 
      begin : idle_state
        /*If there is a CPU request, then compare cache tag*/
        if (cpu_req.valid)
          vstate = compare_tag;
      end: idle_state

      /*compare_tag state*/
      compare_tag : 
      begin :compare_tag_state
        // $display("/*compare_tag state*/");
        // $display("cpu_req.rdindex[TAGMSB:TAGLSB] %0h, tag_read.tag %0h, tag_write.tag %0h, tag_write.valid %0h", cpu_req.rdindex[TAGMSB:TAGLSB], tag_read.tag, tag_write.tag, tag_write.valid);
        /*cache hit (tag match and cache entry is valid)*/
        if (cpu_req.rdindex[TAGMSB:TAGLSB] == tag_read.tag && tag_read.valid) 
        begin :cache_hit
          v_cpu_res.ready = '1;
          /*write hit*/
          if (cpu_req.rw) 
          begin: write_hit
              // $display("/*write hit*/");
            /*read/modify cache line*/
              
            tag_req.we = '1; data_req.we = 1'b1;
            /*no change in tag*/
            tag_write.tag = tag_read.tag;
            // $display("data_req.we; %d, ", data_req.we);
            tag_write.valid = '1;
            /*cache line is dirty*/
            tag_write.dirty = '1;
          end: write_hit
        
          /*xaction is finished*/
          vstate = idle;
        end :cache_hit

        /*cache miss*/
        else 
        begin :cache_miss
          // $display("/*cache miss*/");
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
          // $display("tag_write.dirty %0h, tag_write.valid %0h", tag_write.dirty, tag_write.valid);
          if (tag_read.valid == 1'b0 || tag_read.dirty == 1'b0) 
          begin
            /*wait till a new block is allocated*/
            // $display("wait till a new block is allocated : %0d, tag_write.valid  %0h, tag_write.dirty %0h", data_write, tag_write.valid, tag_write.dirty);
            vstate = allocate;
          end
          else begin : dirty_line_miss
            /*miss with dirty line*/
            // $display("miss with dirty line");
            // v_cpu_res.ready = 1'b0; 
            /*write back address*/
            v_mem_req.addr = {tag_read.tag, cpu_req.rdindex[TAGLSB-1:0]};
            // $display("Allocate, should rw mem");
            // v_mem_req.data = data_write;
            v_mem_req.rw = '1;
            // $display("mem_data.rw, %0h, mem_req.valid %0b", mem_req.rw, mem_req.valid );
            // tag_write.dirty  = '0; //wrote to mem so clean now

            /*wait till write is completed*/
            vstate = write_back;
          end: dirty_line_miss
        end :cache_miss
      end:compare_tag_state

      /*wait for allocating a new cache line*/
      allocate: 
      begin : allocate_state
      /*memory controller has responded*/
      // $display("allocate");
      if (mem_data.ready) 
      begin
        // $display("goes to compare_tag");
        /*re-compare tag for write miss (need modify correct word)*/
        vstate = compare_tag;
        v_mem_req.valid= '0;
        // data_write = mem_data.data; 
        // v_mem_req.data = data_write;
        // v_mem_req.rw = '1; //wrte through, uncomment for wrte bac 
        /*update cache line data*/
        data_req.we = '1;
        end
      end : allocate_state
      /*wait for writing back dirty cache line*/

      write_back : 
      begin :write_back_state
        /*write back is completed*/
        if (mem_data.ready) 
        begin
          /*issue new memory request (allocating a new line)*/
          v_mem_req.valid = '1;
          v_mem_req.rw = '0;
          vstate = allocate;
          // $display("write back") ;
          // v_cpu_res.ready = 1'b1; 

        end
      end :write_back_state
    endcase
  end
  always_ff @(posedge(clk)) 
  begin
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