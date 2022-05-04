
// interface of GPIO input/ouput signal
interface updownstream_if (input logic clk, input logic slowclk);

    // inputs
    logic HRESETn;
    logic cpu_new_max;
    logic [4:0] cpu_client_id;
    logic [15:0] cpu_amount;
    logic cpu_go;
    logic [4:0] exchange_client_id;
    logic [15:0] exchange_amount;
    logic exchange_go;

    
    // output from Upstream processor top
    logic [15:0] accumulated_orders;
    logic [31:0] max_to_trade;
    logic [15:0] cancelled_orders;


    //clocking block for driver
    clocking driver_cb @(posedge slowclk);
        //we don't introudce default input/output clock skew in clocking block
        output HRESETn;
        output cpu_go;
        output cpu_new_max;
        output cpu_client_id;
        output cpu_amount;
        output exchange_client_id;
        output exchange_amount;
        output exchange_go;
    endclocking;

    //clocking block for monitor
    clocking monitor_cb @(posedge slowclk);
        //we don't introudce default input/output clock skew in clocking block
        input HRESETn;
        input cpu_go;
        input cpu_new_max;
        input cpu_client_id;
        input cpu_amount;
        input exchange_client_id;
        input exchange_amount;
        input exchange_go;
        input accumulated_orders;
        input cancelled_orders;
        input max_to_trade;
    endclocking;

    //modport from driver, which specified clock block and data direction
    modport DRIVER(clocking driver_cb,
                input clk, input slowclk);

    //modport from monitor, which specified clock block and data direction
    modport MONITOR(clocking monitor_cb,
                input clk, input slowclk);



endinterface //updown_if