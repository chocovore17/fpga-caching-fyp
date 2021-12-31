// Gets the packet from generator and drive the transaction paket items into interface 
// (interface is connected to DUT) 
`define DRIV_IF seg_if.driver_cb
class driver;
    virtual ahb7seg_if.DRIVER seg_if; //interface modport in driver class
    mailbox gen2driver; // mailbox to hold package/transaction from genrator
    //used to count the number of transactions
    int no_transactions;

    //event
    event drv_done; // driver finish transfering transactions to DUT interface

    //constructor
    function new(virtual ahb7seg_if.DRIVER seg_if, mailbox gen2driver);
        no_transactions = 0;
        //getting the interface
        this.seg_if = seg_if;
        //getting the mailbox handles from  environment 
        this.gen2driver = gen2driver;
    endfunction

    //Reset task, Reset the Interface signals to default/initial values
    task reset;
        $display("--------- [DRIVER] Reset Started ---------");
        @(posedge seg_if.clk);
        `DRIV_IF.HRESETn <= 0;
        `DRIV_IF.HADDR <= 0;
        `DRIV_IF.HWDATA <= 0;
        `DRIV_IF.HTRANS <= 0;
        `DRIV_IF.HWRITE <= 0;
        `DRIV_IF.HSEL <= 0;
        `DRIV_IF.HREADY <= 0;
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
            
            @(posedge seg_if.clk);
            `DRIV_IF.HRESETn <= trans.HRESETn;
            `DRIV_IF.HADDR <= trans.HADDR;
            `DRIV_IF.HWDATA <= trans.HWDATA;
            `DRIV_IF.HTRANS <= trans.HTRANS;
            `DRIV_IF.HWRITE <= trans.HWRITE;
            `DRIV_IF.HSEL <= trans.HSEL;
            `DRIV_IF.HREADY <= trans.HREADY;

            //current iteration of stimulus sent done
            @(posedge seg_if.clk);
            no_transactions++;
            -> drv_done;
            
        end
    endtask

endclass