class transaction;

    rand logic clk;
    rand logic[4:0] client_id;
    rand logic [31:0] amount;
    // rand logic [31:0] HWDATA;
    // rand logic [1:0] HTRANS;
    rand logic new_max;
    rand logic new_order;
    //comment/uncomment correponding constriant for constraned random testing(CRT)
    // constraint c_reset{
    //     client_id == 1'b1;//only select the possible numerical range of each digit
    //     // PARITYSEL == 1'b0;
    // }
    // constraint c_adress{
    //     amount inside{0,4,8,12};//only select the possible 4 address of 4 digits
    // }
    // constraint c_write{
    //     new_max == 1'b1;//always enable ahb write in CRT
    // }
    constraint c_sel{
        new_order == ~new_max;//always enable ahb slave select in CRT
    }
    // constraint c_ready{
    //     HREADY == 1'b1;//always enable ahb write in CRT
    // }
    
    logic [31:0] accumulated_orders;
    logic [31:0] max_to_trade;

    logic thenewmax;
    //upstream outputs

    //displaying randomized values of items 
    function void print(string tag= "");
        $display("T=%0t [%s] transaction information: client_id = 0x%0h amount = 0x%0h new_max = 0x%0h new_order = 0x%0h ",$time, tag, client_id,amount,new_max, new_order);
        // $display("DLS_ERROR = 0b%0b",DLS_ERROR);
    endfunction;

    //displaying output collected from DUT 
    function void print_upstream(string tag= "");
        // $display("T=%0t [%s] upstream transaction information: ", $time, tag);
        $display("accumulated_orders = 0x%0h max_to_trade = 0b%0h thenewmax = 0b%0h ",accumulated_orders, max_to_trade, thenewmax);
    endfunction;

endclass