class transaction;

    rand logic clk;
    rand logic[5:0] cpu_client_id;
    rand logic [31:0] cpu_amount;
    rand logic cpu_new_max;
    rand logic cpu_go;
    rand logic[5:0] exchange_client_id;
    rand logic [31:0] exchange_amount;
    rand logic exchange_go;
    //comment/uncomment correponding constriant for constraned random testing(CRT)
    // constraint c_reset{
    //     cpu_client_id == 1'b1;//only select the possible numerical range of each digit
    //     // PARITYSEL == 1'b0;
    // }
    // constraint c_adress{
    //     cpu_amount inside{0,4,8,12};//only select the possible 4 address of 4 digits
    // }
    // constraint c_write{
    //     cpu_new_max == 1'b1;//always enable ahb write in CRT
    // }
    constraint c_sel{
        cpu_go == ~cpu_new_max;//always enable ahb slave select in CRT
    }
    // constraint c_ready{
    //     HREADY == 1'b1;//always enable ahb write in CRT
    // }
    
    logic [31:0] accumulated_orders;
    logic [31:0] cancelled_orders;

    logic thenewmax;
    //upstream outputs

    //displaying randomized values of items 
    function void print(string tag= "");
        $display("T=%0t [%s] transaction information: cpu_client_id = 0x%0h cpu_amount = 0x%0h cpu_new_max = 0x%0h cpu_go = 0x%0h exchange_client_id = 0x%0h exchange_amount = 0x%0h exchange_go = 0x%0h ",$time, tag, cpu_client_id,cpu_amount,cpu_new_max, cpu_go, exchange_client_id, exchange_amount, exchange_go);
        // $display("DLS_ERROR = 0b%0b",DLS_ERROR);
    endfunction;

    //displaying output collected from DUT 
    function void print_upstream(string tag= "");
        $display("T=%0t [%s] TOP LEVEL transaction information: ", $time, tag);
        $display("accumulated_orders = 0x%0h cancelled_orders = 0b%0h thenewmax = 0b%0h ",accumulated_orders, cancelled_orders, thenewmax);
    endfunction;

endclass