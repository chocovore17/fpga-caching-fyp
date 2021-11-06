
module risk_check(client_id, amount);
   output bool check;
   input  client_id; // cache lne 
   input  amount; // pounds
   
   wire[32:0]   accumulated;
   wire[32:0]   reduced;
   wire[32:0] max
   wire[32:0]   tocheck;
   wire   w1 ; //store the result for now

    always @(client_id,amount)
    begin
      //1: read memory for max, accumulated, reduced 
      //    TODO
      //2: future trade  =accumulated - reduced + future amount
      k  <=  accumulated + amount + (~reduced + 1);
      //3: compare max, future traded   SLT(max, actual)
      SLT(max, futuretraded, w1); // returns 1 for max > future traded (pass),  0 otherwse
      check <= w1 // can we do this, w1 is 1 or 0
    end 

endmodule // returns 1 - fails  or 0 - pass