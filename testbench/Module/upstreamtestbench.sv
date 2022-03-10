// Testbench
module test;

  reg  clk, risk_ok, new_order, new_max,memwr ;
  wire check_risk, send_order, update_max ;
  
  // Instantiate device under test
  upstream_processor UPSTREAMPROCESSOR(.clk(clk),
          .risk_ok(risk_ok),
          .new_order(new_order),
          .new_max(new_max),
          .memwr(memwr),
          .check_risk(check_risk),
          .send_order(send_order),
          .update_max(update_max));
  
  initial begin
    // Dump waves
    $dumpfile("../testbench/outputs/Module/upstreamtestbench.vcd");
    $dumpvars(1, test);
    clk = 0;

    risk_ok = 0;
    new_order = 0;
    new_max = 0;
    memwr = 0;
    $display("\n\n =====================================\nInitial states \n Check risk : %0h", check_risk, "\n Send Order: %0h", send_order, "\nUpdate max: %0h", update_max);

    toggle_clk;
    $display("\n\n =====================================\nIDLE \n states \n Check risk : %0h", check_risk, "\n Send Order: %0h", send_order, "\nUpdate max: %0h", update_max);
    
    new_max = 1;
    toggle_clk;
    $display("\n\n =====================================\nSTATE_NEWMAX \n states \n Check risk : %0h", check_risk, "\n Send Order: %0h", send_order, "\nUpdate max: %0h", update_max);

    memwr  = 1;
    new_max = 0;
    toggle_clk;
    $display("\n\n =====================================\nIDLE \n states \n Check risk : %0h", check_risk, "\n Send Order: %0h", send_order, "\nUpdate max: %0h", update_max);
    
    new_order = 1;
    toggle_clk;
    $display("\n\n =====================================\nSTATE_RISKCHECK \n states \n Check risk : %0h", check_risk, "\n Send Order: %0h", send_order, "\nUpdate max: %0h", update_max);

    new_order = 0;
    risk_ok  = 1;
    toggle_clk;
    $display("\n\n =====================================\nSTATE_SENDORDER \n states \n Check risk : %0h", check_risk, "\n Send Order: %0h", send_order, "\nUpdate max: %0h", update_max);
    
    new_order = 0;
    risk_ok  = 0;
    memwr  = 1;
    toggle_clk;
    $display("\n\n =====================================\nIDLE \n states \n Check risk : %0h", check_risk, "\n Send Order: %0h", send_order, "\nUpdate max: %0h", update_max);
    
    new_order = 1;
    toggle_clk;
    $display("\n\n =====================================\nSTATE_RISKCHECK \n states \n Check risk : %0h", check_risk, "\n Send Order: %0h", send_order, "\nUpdate max: %0h", update_max);

    new_order = 1;
    risk_ok  = 1;
    toggle_clk;
    $display("\n\n =====================================\nSTATE_RISKCHK_SENDORDER \n states \n Check risk : %0h", check_risk, "\n Send Order: %0h", send_order, "\nUpdate max: %0h", update_max);
   
    new_order = 0;
    risk_ok  = 1;
    memwr  = 1;
    toggle_clk;
    $display("\n\n =====================================\n \n STATE_SENDORDER \n Check risk : %0h", check_risk, "\n Send Order: %0h", send_order, "\nUpdate max: %0h", update_max);

    new_order = 0;
    risk_ok  = 0;
    memwr  = 1;
    toggle_clk;
    $display("\n\n =====================================\n \n IDLE \n Check risk : %0h", check_risk, "\n Send Order: %0h", send_order, "\nUpdate max: %0h", update_max);
     
  end
  
  task toggle_clk;
    begin
      #10 clk = ~clk;
      #10 clk = ~clk;
    end
  endtask
  
endmodule