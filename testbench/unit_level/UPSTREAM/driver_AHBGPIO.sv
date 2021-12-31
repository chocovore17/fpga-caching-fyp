// Gets the packet from generator and drive the transaction paket items into interface 
// (interface is connected to DUT) 
`define DRIV_IF gpio_if.driver_cb
class driver;
    virtual ahbgpio_if.DRIVER gpio_if; //interface modport in driver class
    mailbox gen2driver; // mailbox to hold package/transaction from genrator
    //used to count the number of transactions
    int no_transactions;

    //event
    event drv_done; // driver finish transfering transactions to DUT interface

    //constructor
    function new(virtual ahbgpio_if.DRIVER gpio_if, mailbox gen2driver);
        no_transactions = 0;
        //getting the interface
        this.gpio_if = gpio_if;
        //getting the mailbox handles from  environment 
        this.gen2driver = gen2driver;
    endfunction

    //Reset task, Reset the Interface signals to default/initial values
    task reset;
        $display("--------- [DRIVER] Reset Started ---------");
        @(posedge gpio_if.clk);
        `DRIV_IF.HRESETn <= 0;
        `DRIV_IF.HADDR <= 0;
        `DRIV_IF.HWDATA <= 0;
        `DRIV_IF.HTRANS <= 0;
        `DRIV_IF.HWRITE <= 0;
        `DRIV_IF.HSEL <= 0;
        `DRIV_IF.HREADY <= 0;
        `DRIV_IF.GPIOIN <= 0;
        `DRIV_IF.PARITYSEL <= 0; // default parity is even 
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
            
            @(posedge gpio_if.clk);
            `DRIV_IF.HRESETn <= trans.HRESETn;
            `DRIV_IF.HADDR <= trans.HADDR;
            `DRIV_IF.HWDATA <= trans.HWDATA;
            `DRIV_IF.HTRANS <= trans.HTRANS;
            `DRIV_IF.HWRITE <= trans.HWRITE;
            `DRIV_IF.HSEL <= trans.HSEL;
            `DRIV_IF.HREADY <= trans.HREADY;
            `DRIV_IF.GPIOIN <= trans.GPIOIN;

            //current iteration of stimulus sent done
            @(posedge gpio_if.clk);
            no_transactions++;
            -> drv_done;
            
        end
    endtask

endclass