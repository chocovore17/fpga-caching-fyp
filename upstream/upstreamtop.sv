/*
 * top level to call different modules in upstream
 */ 
module upstream_processor_top(clk, client_id, amount, out);
  input  clk;
  input  client_id;
  input amount;
  output out;
  
  reg [1:0] state;
  wire pass_checks;


  always @(client_id,amount)
  begin
        risk_check_top(clk, client_id, amount, pass_checks);
        if pass_checks == 1'b1 begin
            upstream_processor(clk, client_id, amount, out);
        end

  end

endmodule