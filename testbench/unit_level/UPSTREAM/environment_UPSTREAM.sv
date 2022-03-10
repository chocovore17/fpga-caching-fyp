`include "transaction_UPSTREAM.sv"
`include "generator_UPSTREAM.sv"
`include "driver_UPSTREAM.sv"
`include "monitor_UPSTREAM.sv"
`include "scoreboard_UPSTREAM.sv"

class environment;
  
  //generator and driver instance
  generator gen;
  driver    driv;
  //monitor and scoreboard instance
  monitor mon;
  scoreboard scb;
  
  //mailbox handle
  mailbox gen2driv;
  mailbox mon2scb;
  
  //virtual interface handle
  virtual upstream_if up_if;

  event drv_done; // indicate when driver done
  event mon_done; // indicate when monitor done

  int crt_n;
  
  //constructor
  function new(virtual upstream_if up_if);
    //get the interface from test
    this.up_if = up_if;
    
    //creating the mailbox (Same handle will be shared across generator/driver and monitor/scoreboard)
    gen2driv = new;
    mon2scb = new;

    //CRT iteration
    crt_n = 100;
    
    //creating generator, driver, monitor and scoreboard
    gen  = new(gen2driv, crt_n);
    driv = new(up_if,gen2driv);
    mon = new(up_if,mon2scb);
    scb = new(mon2scb);

    // synchronise event between generator and driver; monitor and scoreboard
    gen.drv_done = drv_done;
    driv.drv_done = drv_done;
    mon.mon_done = mon_done;
    scb.mon_done = mon_done;

  endfunction
  
  task pre_test();
    // reset driver to 7 segment display
    driv.reset();
  endtask
  
  task test();
    fork 
      // uncommment/comment corresponding task in generator with different stimulus
      gen.main();
      // gen.run_basic(); 
      // driver receive stimulus/transaction from generator and sent to DUT
      driv.main();
      mon.main();
      scb.main();
    join_any
  endtask
  
  task post_test();
    wait(gen.ended.triggered);
  endtask  
  
  //run task
  task run;
    pre_test();
    test();//call genrator and driver to initiate transactions for testing
    post_test();
  endtask
  
endclass

