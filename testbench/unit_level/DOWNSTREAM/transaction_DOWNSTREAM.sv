class transaction;

    rand logic clk;
    rand logic [4:0] client_id;
    rand logic [15:0] amount;
    
    // comment/uncomment correponding constriant for constraned random testing(CRT)
    // constraint c_reset{
    //     HRESETn inside {1'b1};//only select the possible numerical range of each digit
    // }
    constraint c_adress{
        client_id inside{0,4,8,12,20};//only for now
    }
    constraint c_wdata{
        amount[15:8] == 0;
    }
    
    logic [15:0] cancelled_orders;
    logic memwr;

    //displaying randomized values of items 
    function void print(string tag= "");
        $display("T=%0t [%s] transaction information: client_id = 0x%0h amount = 0x%0h ",$time, tag, client_id,amount);
        // $display("DLS_ERROR = 0b%0b",DLS_ERROR);
    endfunction;

    //displaying output collected from DUT 
    function void print_memwr(string tag= "");
        $display("T=%0t [%s] output transaction information: ", $time, tag);
        $display("cancelled_orders = 0x%0h memwr = 0b%0b ",cancelled_orders,memwr);
    endfunction;

endclass