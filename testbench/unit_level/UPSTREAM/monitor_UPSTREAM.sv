`define MON_IF up_if.monitor_cb
class monitor;
    virtual upstream_if.MONITOR up_if; //interface modport in driver class
    mailbox mon2scb; // mailbox to hold package/transaction from monitor to scoreboard
    event mon_done;// event to synchronise monitor and scoreboard

    //constructor
    function new(virtual upstream_if.MONITOR up_if, mailbox mon2scb);
        //getting the interface
        this.up_if = up_if;
        //getting the mailbox handles from  environment 
        this.mon2scb = mon2scb;
    endfunction    

    task main;
        $display("T=%0t, [MONITOR] starting ---------",$time);
        forever begin
             @(posedge up_if.slowclk);
             if(1'b1==1'b1)begin //valid slave select signal
                // I/O transactions 
                transaction trans = new();
                // general inputs
                trans.new_max = `MON_IF.new_max;
                trans.new_order = `MON_IF.new_order;
                trans.amount = `MON_IF.amount;
                trans.client_id = `MON_IF.client_id;
                // outputs
                trans.accumulated_orders = `MON_IF.accumulated_orders;
                trans.max_to_trade = `MON_IF.max_to_trade;
                trans.thenewmax = `MON_IF.thenewmax;

                @(posedge up_if.slowclk);
                // trans.print("MONITOR");
                mon2scb.put(trans);
                -> mon_done;
             end
        end
    endtask

endclass