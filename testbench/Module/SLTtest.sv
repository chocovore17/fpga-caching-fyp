// Testbench
module test;

  reg[31:0]  A, B;
  reg clk;
  wire Result;
  
  // Instantiate device under test
  SLT SLT(.A(A),
          .B(B),
          .Result(Result));
  
  initial begin
    // Dump waves
    $dumpfile("../outputs/Module/SLTtest.vcd");
    $dumpvars(1, test);

    A = 0;
    B = 20;
    toggle_clk;
    $display("SLT Resultput: %0h", Result, " for inputs %0h", A, ", and %0h", B);

    A = 0;
    B = 10;
    toggle_clk;
    $display("SLT Resultput: %0h", Result, " for inputs %0h", A, ", and %0h", B);

    A = 20;
    B = 15;
    toggle_clk;
    $display("SLT Resultput: %0h", Result, " for inputs %0h", A, ", and %0h", B);

    A = 20;
    B = 20;
    toggle_clk;
    $display("SLT Resultput: %0h", Result, " for inputs %0h", A, ", and %0h", B);

    A = 20000;
    B = 1500;
    toggle_clk;
    $display("SLT Resultput: %0h", Result, " for inputs %0h", A, ", and %0h", B);

    A = 185220;
    B = 225571;
    toggle_clk;
    $display("SLT Resultput: %0h", Result, " for inputs %0h", A, ", and %0h", B);
  end
  
  task toggle_clk;
    begin
      #10 clk = ~clk;
      #10 clk = ~clk;
    end
  endtask
  
endmodule