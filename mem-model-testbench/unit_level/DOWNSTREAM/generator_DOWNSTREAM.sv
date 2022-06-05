// Generator module to produce specified or  randomised stimulus to diver thorugh interface to DUT

class generator;
  
  //declaring transaction class 
  rand transaction trans;
  
  //repeat count, to specify number of items to generate
  int  repeat_count;
  
  //mailbox, to generate and send the packet to driver
  mailbox gen2driv;
  
  //event
  event ended; //generation of stimulus finished
  event drv_done; // driver finish transfering transactions to DUT interface
  
  //constructor
  function new(mailbox gen2driv, int repeat_count = 10);
    //getting the mailbox handle from env, in order to share the transaction packet between the generator and driver, the same mailbox is shared between both.
    this.gen2driv = gen2driv;
    this.repeat_count = repeat_count;
  endfunction
  
    //main task, generates(create and randomizes) the repeat_count number of transaction packets and puts into mailbox
    task main();
        $display("T=%0t [Generator] starting", $time);
        $display("repeat count = %0d", repeat_count);
        repeat(repeat_count) begin
          trans = new();
          if( !trans.randomize() ) $fatal("Gen:: trans randomization failed");      
          gen2driv.put(trans);
          @(drv_done);
        end
        $display("T=%0t [Generator] Done generation", $time);
        -> ended; 
    endtask

    task run_basic();
        // simple basic contrant test cases genrated
        trans = new();
        if( !trans.randomize() ) $fatal("Gen:: trans randomization failed");
        gen2driv.put(trans);
        // wait(drv_done.triggered);
        @(drv_done)
        $display("T=%0t [Generator] Driver done event triggered", $time);

        -> ended; //trigger generation ending event to notify environment
        $display("T=%0t [Generator] Done generation", $time);
    endtask
  
endclass