// Gets the packet from generator and drive the transaction paket items into interface 
// (interface is connected to DUT) 
`define DRIV_IF up_if.driver_cb
class driver;
    virtual upstream_if.DRIVER up_if; //interface modport in driver class
    mailbox gen2driver; // mailbox to hold package/transaction from genrator
    //used to count the number of transactions
    int no_transactions;

    //event
    event drv_done; // driver finish transfering transactions to DUT interface

    //constructor
    function new(virtual upstream_if.DRIVER up_if, mailbox gen2driver);
        no_transactions = 0;
        //getting the interface
        this.up_if = up_if;
        //getting the mailbox handles from  environment 
        this.gen2driver = gen2driver;
    endfunction

    //Reset task, Reset the Interface signals to default/initial values
    task reset;
        $display("--------- [DRIVER] Reset Started ---------");
        @(posedge up_if.clk);
        `DRIV_IF.client_id <= 0;
        `DRIV_IF.amount <= 0;
        `DRIV_IF.new_order <= 0;
        `DRIV_IF.new_max <= 0;
        // `DRIV_IF.accumulated_orders <= 0;
        // `DRIV_IF.max_to_trade <= 0;
        // `DRIV_IF.thenewmax <= 0;
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
            
            @(posedge up_if.slowclk);
            `DRIV_IF.client_id <= trans.client_id;
            `DRIV_IF.amount <= trans.amount;
            `DRIV_IF.new_order <= trans.new_order;
            `DRIV_IF.new_max <= trans.new_max;
            // `DRIV_IF.accumulated_orders <= trans.accumulated_orders;
            // `DRIV_IF.max_to_trade <= trans.max_to_trade;
            // `DRIV_IF.HREADY <= trans.HREADY;
            // `DRIV_IF.GPIOIN <= trans.GPIOIN;

            //current iteration of stimulus sent done
            @(posedge up_if.slowclk);
            no_transactions++;
            -> drv_done;
            
        end
    endtask

endclass