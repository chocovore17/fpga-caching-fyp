// Testbench
module get_cxltest;

  reg[31:0]  amount;
  reg clk;
  reg[4:0] client_id;
  wire ack;
  
  // Instantiate device under test
  get_Cxl get_Cxl(.clk(clk),
          .client_id(client_id),
          .amount(amount),
          .ack(ack));
  
  initial begin
    // Dump waves
    $dumpfile("../testbench/outputs/Module/get_cxltest.vcd");
    $dumpvars(1, get_cxltest);
    clk = 0;

    toggle_clk;
    $display("Get_Cxl module output: %0h", ack, " for client_id value %0h", client_id, ", and amount %0h", amount);

    client_id = 5'h1B;
    amount = 32'h000000C5;
    toggle_clk;
    $display("Get_Cxl module output: %0h", ack, " for client_id value %0h", client_id, ", and amount %0h", amount);

    client_id = 5'h1B;
    amount = 32'h000000C5;
    toggle_clk;
    $display("Get_Cxl module output: %0h", ack, " for client_id value %0h", client_id, ", and amount %0h", amount);

    client_id = 5'h08;
    amount = 32'h000000C5;
    toggle_clk;
    $display("Get_Cxl module output: %0h", ack, " for client_id value %0h", client_id, ", and amount %0h", amount);


    client_id = 5'h08;
    amount = 32'h000000C5;
    toggle_clk;
    $display("Get_Cxl module output: %0h", ack, " for client_id value %0h", client_id, ", and amount %0h", amount);
    
    client_id = 5'h08;
    amount = 32'h000020C5;
    toggle_clk;
    $display("Get_Cxl module output: %0h", ack, " for client_id value %0h", client_id, ", and amount %0h", amount);

  end
  
  task toggle_clk;
    begin
      #10 clk = ~clk;
      #10 clk = ~clk;
    end
  endtask
  
endmodule