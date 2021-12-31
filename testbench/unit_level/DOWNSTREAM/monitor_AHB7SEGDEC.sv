`define MON_IF seg_if.monitor_cb
class monitor;
    virtual ahb7seg_if.MONITOR seg_if; //interface modport in driver class
    mailbox mon2scb; // mailbox to hold package/transaction from monitor to scoreboard
    event mon_done;// event to synchronise monitor and scoreboard

    //constructor
    function new(virtual ahb7seg_if.MONITOR seg_if, mailbox mon2scb);
        //getting the interface
        this.seg_if = seg_if;
        //getting the mailbox handles from  environment 
        this.mon2scb = mon2scb;
    endfunction    

    task main;
        $display("T=%0t, [MONITOR] starting ---------",$time);
        forever begin
             @(posedge seg_if.clk);
             if(`MON_IF.HSEL)begin //valid slave select signal
                transaction trans = new();
                trans.HRESETn = `MON_IF.HRESETn;
                trans.HADDR = `MON_IF.HADDR;
                trans.HWDATA = `MON_IF.HWDATA;
                trans.HTRANS = `MON_IF.HTRANS;
                trans.HWRITE = `MON_IF.HWRITE;
                trans.HSEL = `MON_IF.HSEL;
                trans.HREADY = `MON_IF.HREADY;
                trans.HRDATA = `MON_IF.HRDATA;
                trans.HREADYOUT = `MON_IF.HREADYOUT;
                trans.seg = `MON_IF.seg;
                trans.an = `MON_IF.an;
                trans.dp = `MON_IF.dp;
                trans.DLS_ERROR = `MON_IF.DLS_ERROR;

                @(posedge seg_if.clk);
                // trans.print("MONITOR");
                mon2scb.put(trans);
                -> mon_done;
             end
        end
    endtask

endclass