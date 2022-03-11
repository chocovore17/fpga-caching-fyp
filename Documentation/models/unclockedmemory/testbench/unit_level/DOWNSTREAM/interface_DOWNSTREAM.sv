
// interface of 7-segment display controller input/ouput signal
interface dwnstrmproc_if (input logic clk, input logic slowclk);

    logic [4:0]  client_id;
    logic [15:0] amount;
    
    // output from DUT
    logic [15:0] cancelled_orders;
    // logic memwr; // RAM bool output & State machine input

    //clocking block for driver
    clocking driver_cb @(posedge slowclk);
        //we don't introudce default input/output clock skew in clocking block
        output client_id;
        output amount;
    endclocking;

    //clocking block for monitor
    clocking monitor_cb @(posedge slowclk);
        //we don't introudce default input/output clock skew in clocking block
        input client_id;
        input amount;
        input cancelled_orders;
        // input memwr;
    endclocking;

    //modport from driver, which specified clock block and data direction
    modport DRIVER(clocking driver_cb,
                input clk, input slowclk);

    //modport from monitor, which specified clock block and data direction
    modport MONITOR(clocking monitor_cb,
                input clk, input slowclk);



endinterface //7dwnstrm_if