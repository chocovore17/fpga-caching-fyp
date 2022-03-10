
// interface of GPIO input/ouput signal
interface upstream_if (input logic clk, input logic slowclk);

    // inputs
    logic new_max;
    logic [4:0] client_id;
    logic [31:0] amount;
    logic new_order;
    
    // output from Upstream processor top
    logic [31:0] accumulated_orders;
    logic [31:0] max_to_trade;
    logic thenewmax;


    //clocking block for driver
    clocking driver_cb @(posedge slowclk);
        //we don't introudce default input/output clock skew in clocking block
        output new_order;
        output new_max;
        output client_id;
        output amount;
    endclocking;

    //clocking block for monitor
    clocking monitor_cb @(posedge slowclk);
        //we don't introudce default input/output clock skew in clocking block
        input new_order;
        input new_max;
        input client_id;
        input amount;
        input thenewmax;
        input accumulated_orders;
        input max_to_trade;
    endclocking;

    //modport from driver, which specified clock block and data direction
    modport DRIVER(clocking driver_cb,
                input clk, input slowclk);

    //modport from monitor, which specified clock block and data direction
    modport MONITOR(clocking monitor_cb,
                input clk, input slowclk);



endinterface //up_if