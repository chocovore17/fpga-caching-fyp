 `include "SLT.sv"


module risk_check(accumulated_orders, max_to_trade, cancelled_orders,  amount, check);
   output check;
   input[31:0]  accumulated_orders, max_to_trade, cancelled_orders, amount;
   
   wire   w1 ; //store the result for now

    // 1: : future trade  =accumulated - reduced + future amount
    // futuretraded =  accumulated_orders + amount + (~cancelled_orders + 1);
    //2: compare max, future traded   SLT(max, actual)
    SLT SLT(.A(max_to_trade),
        .B(accumulated_orders + amount + (~cancelled_orders + 1)),
        .Result(w1));
    //3: assign to result 

    assign check = w1; 

  endmodule // returns 1 - fails  or 0 - pass