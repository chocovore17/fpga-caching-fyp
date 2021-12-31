`define MON_IF gpio_if.monitor_cb
class monitor;
    virtual ahbgpio_if.MONITOR gpio_if; //interface modport in driver class
    mailbox mon2scb; // mailbox to hold package/transaction from monitor to scoreboard
    event mon_done;// event to synchronise monitor and scoreboard

    //constructor
    function new(virtual ahbgpio_if.MONITOR gpio_if, mailbox mon2scb);
        //getting the interface
        this.gpio_if = gpio_if;
        //getting the mailbox handles from  environment 
        this.mon2scb = mon2scb;
    endfunction    

    task main;
        $display("T=%0t, [MONITOR] starting ---------",$time);
        forever begin
             @(posedge gpio_if.clk);
             if(`MON_IF.HSEL)begin //valid slave select signal
                // I/O transactions 
                transaction trans = new();
                // general inputs
                trans.HRESETn = `MON_IF.HRESETn;
                trans.HADDR = `MON_IF.HADDR;
                trans.HWDATA = `MON_IF.HWDATA;
                trans.HTRANS = `MON_IF.HTRANS;
                trans.HWRITE = `MON_IF.HWRITE;
                trans.HSEL = `MON_IF.HSEL;
                trans.HREADY = `MON_IF.HREADY;
                // GPIO specific inputs
                trans.GPIOIN = `MON_IF.GPIOIN;
                trans.PARITYSEL = `MON_IF.PARITYSEL;
                // outputs
                trans.HRDATA = `MON_IF.HRDATA;
                trans.HREADYOUT = `MON_IF.HREADYOUT;
                trans.GPIOOUT = `MON_IF.GPIOOUT;

                @(posedge gpio_if.clk);
                // trans.print("MONITOR");
                mon2scb.put(trans);
                -> mon_done;
             end
        end
    endtask

endclass