`define MON_IF updown_if.monitor_cb
class monitor;
    virtual updownstream_if.MONITOR updown_if; //interface modport in driver class
    mailbox mon2scb; // mailbox to hold package/transaction from monitor to scoreboard
    event mon_done;// event to synchronise monitor and scoreboard

    //constructor
    function new(virtual updownstream_if.MONITOR updown_if, mailbox mon2scb);
        //getting the interface
        this.updown_if = updown_if;
        //getting the mailbox handles from  environment 
        this.mon2scb = mon2scb;
    endfunction    

    task main;
        $display("T=%0t, [MONITOR] starting ---------",$time);
        forever begin
             @(posedge updown_if.slowclk);
             if(1'b1==1'b1)begin //valid slave select signal
                // I/O transactions 
                transaction trans = new();
                // general inputs
                trans.HRESETn = `MON_IF.HRESETn;
                trans.cpu_new_max = `MON_IF.cpu_new_max;
                trans.cpu_go = `MON_IF.cpu_go;
                trans.cpu_amount = `MON_IF.cpu_amount;
                trans.cpu_client_id = `MON_IF.cpu_client_id;
                trans.exchange_client_id = `MON_IF.exchange_client_id;
                trans.exchange_amount = `MON_IF.exchange_amount;
                trans.exchange_go = `MON_IF.exchange_go;
                // outputs
                trans.accumulated_orders = `MON_IF.accumulated_orders;
                trans.cancelled_orders = `MON_IF.cancelled_orders;
                trans.max_to_trade  = `MON_IF.max_to_trade;
                @(posedge updown_if.slowclk);
                // trans.print("MONITOR");
                mon2scb.put(trans);
                -> mon_done;
             end
        end
    endtask

endclass