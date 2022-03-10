class scoreboard;
    mailbox mon2scb; // mailbox to hold package/transaction from monitor to scoreboard
    event mon_done;// event to synchronise monitor and scoreboard

        //constructor
    function new(mailbox mon2scb);
        this.mon2scb = mon2scb;
    endfunction

    task main;
        $display("T=%0t, [SCOREBOARD] starting ---------",$time);
        forever begin
            transaction trans;
            mon2scb.get(trans);
            trans.print("SCOREBOARD");
            trans.print_downstream("SCOREBOARD");
            @(mon_done);
        end
    endtask

endclass