/*
 * top level to call different modules in upstream
 compile with the following flags in icarus verilog:  -Wall -g2012 bc inputs/outputs fed back
 */ 

 `include "mem_model_bs/shared/ramdownstream.sv"
 `include "mem_model_bs/shared/cache_def.sv"
 import cache_def::*;


module downstream_top( clk, client_id, amount, downdatareq /*to display testing, cpu_client_id*/);
  input[4:0]  client_id;
  input clk;

  input[15:0] amount;
  output cpu_req_type downdatareq; //used outside, by ramdownstream
  reg old_client;
  reg old_amount;


  always @(client_id, amount)
  begin 
    downdatareq.wrindex[13:4] = client_id;
    downdatareq.rw = ((client_id!=old_client) || (old_amount!=amount));
    downdatareq.valid = 1'b1;
    downdatareq.data =amount;
    old_amount = amount;
    old_client = client_id;
    // $display("downdatareq.rw",downdatareq.rw);  
    // SVA to check write enable logic 
downstream_write_enable: assert property (
  @(posedge clk) // throws an error if two states high
  downdatareq.rw == 1'b1
    )
  else begin 
    $error ("should be writing to downstream memory");
  end //

   
end 
endmodule