// Gets the packet from generator and drive the transaction paket items into interface 
// (interface is connected to DUT) 
`define DRIV_IF updown_if.driver_cb
class driver;
    virtual updownstream_if.DRIVER updown_if; //interface modport in driver class
    mailbox gen2driver; // mailbox to hold package/transaction from genrator
    //used to count the number of transactions
    int no_transactions;

    //event
    event drv_done; // driver finish transfering transactions to DUT interface

    //constructor
    function new(virtual updownstream_if.DRIVER updown_if, mailbox gen2driver);
        no_transactions = 0;
        //getting the interface
        this.updown_if = updown_if;
        //getting the mailbox handles from  environment 
        this.gen2driver = gen2driver;
    endfunction

    //Reset task, Reset the Interface signals to default/initial values
    task reset;
        $display("--------- [DRIVER] Reset Started ---------");
        @(posedge updown_if.clk);
        `DRIV_IF.cpu_client_id <= 0;
        `DRIV_IF.cpu_amount <= 0;
        `DRIV_IF.cpu_go <= 0;
        `DRIV_IF.cpu_new_max <= 0;
        `DRIV_IF.exchange_client_id <= 0;
        `DRIV_IF.exchange_amount <= 0;
        `DRIV_IF.exchange_go <= 0;
        // `DRIV_IF.GPIOIN <= 0;
        // `DRIV_IF.PARITYSEL <= 0; // default parity is even 
        $display("--------- [DRIVER] Reset Ended ---------");
    endtask

      //drivers the transaction items to interface signals
    task main;
        $display("T=%0t, [DRIVER] starting ---------",$time);
        forever begin
            transaction trans;
            gen2driver.get(trans); // driver receive transaction from generator
            // trans.print("DRIVER"); // print transaction information
            // $display("T=%0t, [DRIVER-TRANSFER: %0d] ---------",$time,no_transactions);
            
            @(posedge updown_if.slowclk);
            `DRIV_IF.cpu_client_id <= trans.cpu_client_id;
            `DRIV_IF.cpu_amount <= trans.cpu_amount;
            `DRIV_IF.cpu_go <= trans.cpu_go;
            `DRIV_IF.cpu_new_max <= trans.cpu_new_max;
            `DRIV_IF.exchange_client_id <= trans.exchange_client_id;
            `DRIV_IF.exchange_amount <= trans.exchange_amount;
            `DRIV_IF.exchange_go <= trans.exchange_go;
            // `DRIV_IF.GPIOIN <= trans.GPIOIN;

            //current iteration of stimulus sent done
            @(posedge updown_if.slowclk);
            no_transactions++;
            -> drv_done;
            
        end
    endtask

endclass