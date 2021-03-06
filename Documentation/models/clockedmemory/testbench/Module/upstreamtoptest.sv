// Testbench
module test;

  reg  clk, ack, memwr;
  wire out;
  
  // Instantiate device under test
  fsm DOWNSTREAMPROCESSOR(.clk(clk),
          .ack(ack),
          .memwr(memwr),
          .out(out);
  
  initial begin
    // Dump waves
    $dumpfile("../outputs/Module/upstream.vcd");
    $dumpvars(1, test);

    clk = 0;
    ack = 0;
    memwr = 0;
    $display("Initial out: %0h", out);

    toggle_clk;
    $display("IDLE  out: %0h", out);
    
    ack = 1;
    toggle_clk;
    $display("STATE_1  out: %0h", out);

    memwr  = 1;
    toggle_clk;
    $display("IDLE  out: %0h", out, " memwr is 1, ack 1");
    
    ack = 0;
    toggle_clk;
    $display("IDLE  out: %0h", out, " ack back to 0");
  end
  
  task toggle_clk;
    begin
      #10 clk = ~clk;
      #10 clk = ~clk;
    end
  endtask
  
endmodule