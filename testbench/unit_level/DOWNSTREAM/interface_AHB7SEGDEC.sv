
// interface of 7-segment display controller input/ouput signal
interface ahb7seg_if (input logic clk);

    logic HRESETn;
    logic [31:0] HADDR;
    logic [31:0] HWDATA;
    logic [1:0] HTRANS;
    logic HWRITE;
    logic HSEL;
    logic HREADY;
    
    // output from DUT
    logic [31:0] HRDATA;
    logic HREADYOUT;

    //7segment display
    logic [6:0] seg;
    logic [3:0] an;
    logic dp;

    //DLS error logic signal
    logic DLS_ERROR;

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
        input HRDATA;
        input HREADYOUT;
        input seg;
        input an;
        input dp;
        input DLS_ERROR;
    endclocking;

    //modport from driver, which specified clock block and data direction
    modport DRIVER(clocking driver_cb,
                input clk);

    //modport from monitor, which specified clock block and data direction
    modport MONITOR(clocking monitor_cb,
                input clk);



endinterface //7seg_if