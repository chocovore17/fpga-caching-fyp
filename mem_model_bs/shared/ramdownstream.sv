/* 
* Random Access Memory (RAM) with
* 1 read port and 1 write port (for now )
downstream_address_write = clientID 
data_write = value of accumulated cancelled order (32 bits)
*/
`include "mem_model_bs/shared/cache_def.sv"
import cache_def::*;
//  parameter int TAGDOWNMAX = 32; //tag msb

module dm_data_downstream(clk,
  data_req,//data request/command, e.g. RW, valid
  data_write, //write port (128-bit line)
  data_read); //read port
  input  clk;
  input cache_req_type data_req;//data request/command, e.g. RW, valid
  input cache_data_type data_write; //write port (128-bit line)
  output cache_data_type data_read; //read port
  cache_data_type data_mem[0:32];
  reg[4:0] i;

  initial begin
    $display("Loading downstream rom.");
    $readmemh("mem_model_bs/shared/rom_empty.mem", data_mem);
    // $displayb("%p", memory);
  end

  assign data_read = data_mem[data_req.rdindex];
  always @(posedge(clk)) begin
    if (data_req.we) begin
      data_mem[data_req.wrindex] <= data_write+data_mem[data_req.wrindex];
    end
  end
endmodule



/*cache: tag memory, single port, 1024 blocks*/
module dm_cache_tag_downstream(input bit clk, //write clock
  input cache_req_type tag_req, //tag request/command, e.g. RW, valid
  input cache_tag_type tag_write,//write port
  output cache_tag_type tag_read);//read port
  timeunit 1ns; timeprecision 1ps;

  cache_tag_type tag_mem[0:32];
  initial begin
  for (int i=0; i<1024; i++)
    tag_mem[i] = '0;
  end
  assign tag_read = tag_mem[tag_req.rdindex];
  always @(posedge(clk)) begin
    if (tag_req.we)
      tag_mem[tag_req.wrindex] <= tag_mem[tag_req.wrindex]+tag_write;
    end
endmodule



module downmem_controller(input bit clk, //write clock
  output mem_data_type mem_data_down, //memory response (memory->cache)
  // input change_max,
  input mem_req_type mem_req) ;//memory request (cache->memory))
  reg[4:0] i;
  reg[127:0] datav;
  cache_data_type memory[0:121];
  assign mem_data_down.data = datav;
  assign mem_data_down.ready = 1'b1;

  initial begin
    $display("Loading downstream memory.");
    $readmemh("code/shared/rom_empty.mem", memory);
    // $displayb("%p", memory);
  end
  always @(mem_req.addr) begin
    // mem_data_down.ready = 1'b0;   
    // $display("mem_data_down.ready from controller %0h mem.", mem_data_down.ready);   
    datav = memory[mem_req.addr];
    for (i=0; i<5; i=i+1)begin
          @(posedge clk) ; 
        end
        wait (i=== 5); //Implementation 1   
        // mem_data_down.ready = 1'b1;   
  end 

  always @(mem_req.rw) begin
    // if (mem_req.rw) begin
        memory[mem_req.wraddr]<=  memory[mem_req.wraddr]+ mem_req.data; //+memory[data_req.index];
      // end
      for (i=0; i<7; i=i+1)
          @(posedge clk) ; 
    wait (i=== 7); //Implementation 1   
    end   
  endmodule


/*cache finite state machine*/
module dm_cache_fsm_downstream(input bit clk, input bit rst,
    input cpu_req_type cpu_req, //CPU request input (CPU->cache)
    input mem_data_type mem_data_down, //memory response (memory->cache)
    output mem_req_type mem_req, //memory request (cache->memory)
    output cpu_result_type cpu_res //cache result (cache->CPU)
  );
  timeunit 1ns;
  timeprecision 1ps;
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
    v_cpu_res = '{0, 0}; 
    tag_write = '{0, 0, 0};
    /*read tag by default*/
    tag_req.we = '0;
    /*direct map index for tag*/
    tag_req.rdindex = cpu_req.rdindex[13:4];
    tag_req.wrindex = cpu_req.wrindex[13:4];

    /*read current cache line by default*/
    data_req.we = '0;
    /*direct map index for cache data*/
    data_req.rdindex = cpu_req.rdindex[13:4];
    data_req.wrindex = cpu_req.wrindex[13:4];

    /*modify correct word (32-bit) based on address*/
    data_write = data_read;
    // TODO: VERFY WRTE CASE 
    case(cpu_req.wrindex[3:2])
    2'b00:data_write[31:0] = cpu_req.data;
    // 2'b01:data_write[63:32] = cpu_req.data;
    // 2'b10:data_write[95:64] = cpu_req.data;
    // 2'b11:data_write[127:96] = cpu_req.data;
    endcase

    /*read out correct word(32-bit) from cache (to CPU)*/
    case(cpu_req.rdindex[3:2])
    2'b00:v_cpu_res.data = data_read[31:0];
    // 2'b01:v_cpu_res.data = data_read[63:32];
    // 2'b10:v_cpu_res.data = data_read[95:64];
    // 2'b11:v_cpu_res.data = data_read[127:96];
    endcase
    // $display("v_cpu_res.data: %0h, cpu_req.data: %0h, vstate %0h", v_cpu_res.data, cpu_req.data, vstate);
    // $display("rd from: %0h, wr from: %0h", cpu_req.rdindex,cpu_req.wrindex);


    // TODO: ADD RD/WR MEM REQ ADDR
    /*memory request address (sampled from CPU request)*/
    v_mem_req.addr = cpu_req.rdindex;
    v_mem_req.wraddr = cpu_req.wrindex;
    /*memory request data (used in write)*/
    // v_mem_req.data = data_read;
    v_mem_req.rw = '0;
    v_mem_req.data = data_write;


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
        // $display("cpu_req.rdindex[TAGMSB:TAGLSB] == tag_read.tag %0h, tag_read.valid %0h", (cpu_req.rdindex[TAGMSB:TAGLSB] == tag_read.tag) , tag_read.valid);
        /*cache hit (tag match and cache entry is valid)*/
        if (cpu_req.rdindex[TAGMSB:TAGLSB] == tag_read.tag && tag_read.valid) begin
        v_cpu_res.ready = '1;

        /*write hit*/
        if (cpu_req.rw) begin
          /*read/modify cache line*/
          tag_req.we = '1; data_req.we = '1;
          /*no change in tag*/
          tag_write.tag = tag_read.tag;
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
        tag_write.tag = cpu_req.wrindex[TAGMSB:TAGLSB];
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
          // TODO: RD OR WRTE CHEC
          v_mem_req.addr = {tag_read.tag, cpu_req.rdindex[TAGLSB-1:0]};
          v_mem_req.wraddr = {tag_read.tag, cpu_req.wrindex[TAGLSB-1:0]};
          v_mem_req.rw = '1;
          /*wait till write is completed*/
          vstate = write_back;
          end
        end
      end
      /*wait for allocating a new cache line*/
      allocate: begin
        /*memory controller has responded*/
        // if (mem_data_down.ready) begin
        /*re-compare tag for write miss (need modify correct word)*/
        vstate = compare_tag;
        data_write = mem_data_down.data;
        /*update cache line data*/
        data_req.we = '1;
        // end
      end
      /*wait for writing back dirty cache line*/
      write_back : begin
        /*write back is completed*/
        // if (mem_data_down.ready) begin
        /*issue new memory request (allocating a new line)*/
        v_mem_req.valid = '1;
        v_mem_req.rw = '0;

        vstate = allocate; 
      end
      // end
    endcase
  end
  always_ff @(posedge(clk)) begin
    if (rst)
      rstate <= idle; //reset to idle state
    else
      rstate <= vstate;
  end
  /*connect cache tag/data memory*/
  dm_cache_tag_downstream ctag(.*);
  dm_data_downstream cdata(.*);
  downmem_controller cmem(.*);

endmodule