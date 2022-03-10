`define MON_IF dwnstrm_if.monitor_cb
class monitor;
    virtual dwnstrmproc_if.MONITOR dwnstrm_if; //interface modport in driver class
    mailbox mon2scb; // mailbox to hold package/transaction from monitor to scoreboard
    event mon_done;// event to synchronise monitor and scoreboard

    //constructor
    function new(virtual dwnstrmproc_if.MONITOR dwnstrm_if, mailbox mon2scb);
        //getting the interface
        this.dwnstrm_if = dwnstrm_if;
        //getting the mailbox handles from  environment 
        this.mon2scb = mon2scb;
    endfunction    

    task main;
        $display("T=%0t, [MONITOR] starting ---------",$time);
        forever begin
             @(posedge dwnstrm_if.clk);
            //  if(`MON_IF.HSEL)begin //valid slave select signal
                transaction trans = new();
                trans.client_id = `MON_IF.client_id;
                trans.amount = `MON_IF.amount;
                trans.cancelled_orders = `MON_IF.cancelled_orders;
                trans.memwr = `MON_IF.memwr;
                @(posedge dwnstrm_if.clk);
                // trans.print("MONITOR");
                mon2scb.put(trans);
                -> mon_done;
            //  end
        end
    endtask

endclass