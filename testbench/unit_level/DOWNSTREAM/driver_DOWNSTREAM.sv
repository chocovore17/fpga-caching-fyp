// Gets the packet from generator and drive the transaction paket items into interface 
// (interface is connected to DUT) 
`define DRIV_IF dwnstrm_if.driver_cb
class driver;
    virtual dwnstrmproc_if.DRIVER dwnstrm_if; //interface modport in driver class
    mailbox gen2driver; // mailbox to hold package/transaction from genrator
    //used to count the number of transactions
    int no_orders;

    //event
    event drv_done; // driver finish transfering transactions to DUT interface

    //constructor
    function new(virtual dwnstrmproc_if.DRIVER dwnstrm_if, mailbox gen2driver);
        no_orders = 0;
        //getting the interface
        this.dwnstrm_if = dwnstrm_if;
        //getting the mailbox handles from  environment 
        this.gen2driver = gen2driver;
    endfunction

    //Reset task, Reset the Interface signals to default/initial values
    task reset;
        $display("--------- [DRIVER] Reset Started ---------");
        @(posedge dwnstrm_if.clk);
        `DRIV_IF.client_id <= 0;
        `DRIV_IF.amount <= 0;
        $display("--------- [DRIVER] Reset Ended ---------");
    endtask

      //drivers the transaction items to interface signals
    task main;
        $display("T=%0t, [DRIVER] starting ---------",$time);
        forever begin
            transaction trans;
            gen2driver.get(trans); // driver receive transaction from generator
            // trans.print("DRIVER"); // print transaction information
            // $display("T=%0t, [DRIVER-TRANSFER: %0d] ---------",$time,no_orders);
            
            @(posedge dwnstrm_if.clk);
            `DRIV_IF.client_id <= trans.client_id;
            `DRIV_IF.amount <= trans.amount;
            //current iteration of stimulus sent done
            @(posedge dwnstrm_if.clk);
            no_orders++;
            -> drv_done;
            
        end
    endtask

endclass