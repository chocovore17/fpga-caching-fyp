
// interface of GPIO input/ouput signal
interface ahbgpio_if (input logic clk);

    // inputs
    logic HRESETn;
    logic [31:0] HADDR;
    logic [31:0] HWDATA;
    logic [1:0] HTRANS;
    logic HWRITE;
    logic HSEL;
    logic HREADY;
    logic [16:0] GPIOIN;
    logic PARITYSEL; 
    
    // output from DUT
    logic [31:0] HRDATA;
    logic HREADYOUT;

    // GPIO output signal 
    logic[16:0] GPIOOUT;
    
    //GPIO parity error signal 
    logic PARITYERR;

    //clocking block for driver
    clocking driver_cb @(posedge clk);
        //we don't introudce default input/output clock skew in clocking block
        output HRESETn;
        output HADDR;
        output HWDATA;
        output HTRANS;
        output HWRITE;
        output HSEL;
        output HREADY;
        output GPIOIN; 
        output PARITYSEL;
    endclocking;

    //clocking block for monitor
    clocking monitor_cb @(posedge clk);
        //we don't introudce default input/output clock skew in clocking block
        input HRESETn;
        input HADDR;
        input HWDATA;
        input HTRANS;
        input HWRITE;
        input HSEL;
        input HREADY;
        input GPIOIN; 
        input PARITYSEL;
        input HRDATA;
        input HREADYOUT;
        input GPIOOUT;
        input PARITYERR;
    endclocking;

    //modport from driver, which specified clock block and data direction
    modport DRIVER(clocking driver_cb,
                input clk);

    //modport from monitor, which specified clock block and data direction
    modport MONITOR(clocking monitor_cb,
                input clk);



endinterface //gpio_if