class transaction;

    rand logic HCLK;
    rand logic HRESETn;
    rand logic [31:0] HADDR;
    rand logic [31:0] HWDATA;
    rand logic [1:0] HTRANS;
    rand logic HWRITE;
    rand logic HSEL;
    rand logic HREADY;
    rand logic  [16:0] GPIOIN;
    // parity
    rand logic PARITYSEL;
    //comment/uncomment correponding constriant for constraned random testing(CRT)
    // constraint c_reset{
    //     HRESETn == 1'b1;//only select the possible numerical range of each digit
    //     // PARITYSEL == 1'b0;
    // }
    constraint c_adress{
        HADDR inside{0,4,8,12};//only select the possible 4 address of 4 digits
    }
    constraint c_wdata{
        HWDATA[31:16] == 0;
        HWDATA[15:0] inside {16'h0000, 16'h0001};
        // HWDATA[7] inside {1'b0,1'b1};
        // HWDATA[6:0] inside{[0:15]};//only select the possible numerical range of each digit
    }
    constraint c_trans{
        HTRANS[1] == 1'b1;//always enable ahb trans in CRT
    }
    // constraint c_write{
    //     HWRITE == 1'b1;//always enable ahb write in CRT
    // }
    constraint c_sel{
        HSEL == 1'b1;//always enable ahb slave select in CRT
    }
    // constraint c_ready{
    //     HREADY == 1'b1;//always enable ahb write in CRT
    // }
    
    constraint c_gpioin_even {
           GPIOIN[0] == ^GPIOIN[16:1];
        }
    constraint c_even{
        PARITYSEL == 1'b0;// set parity to even
    }
    
    logic [31:0] HRDATA;
    logic HREADYOUT;
    //gpio outputs
    logic [16:0] GPIOOUT;
    logic PARITYERR;

    //displaying randomized values of items 
    function void print(string tag= "");
        $display("T=%0t [%s] transaction information: HRESETn = 0x%0h HADDR = 0x%0h HWDATA = 0x%0h HTRANS = 0x%0h HWRITE = 0x%0h GPIOIN = 0x%0h PARITYSEL = 0x%0h ",$time, tag, HRESETn,HADDR,HWDATA,HTRANS, HWRITE, GPIOIN, PARITYSEL);
        // $display("DLS_ERROR = 0b%0b",DLS_ERROR);
    endfunction;

    //displaying output collected from DUT 
    function void print_gpio(string tag= "");
        $display("T=%0t [%s] gpio transaction information: ", $time, tag);
        $display("HRDATA = 0x%0h GPIOOUT = 0b%0b PARITYERR = 0b%0b ",HRDATA, GPIOOUT, PARITYERR);
    endfunction;

endclass