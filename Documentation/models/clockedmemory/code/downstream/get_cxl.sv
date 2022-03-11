
// NOTE; with current implementaton, will have to send a "fake" cancel to initiate registers 

module get_Cxl(client_id, amount, ack, clk);

  input  clk; // for now use same clock to read and write, just not at same time
  input[4:0]  client_id;
  input[15:0] amount;
  output ack;
  reg[4:0] past_client;
  reg[31:0] past_amount;
  reg new_cancel;
  assign ack = new_cancel;
  // always @(client_id, amount) begin 
  //   new_cancel <= 1;
  // end 
  always @(posedge clk)
  begin 
	  if (client_id != past_client)  new_cancel <= 1;
	  else if (amount != past_amount) new_cancel <=1; 
    else  new_cancel <= 0;
	  past_client <= client_id;
	  past_amount <= amount;  
  end
endmodule