`include "environment_AHB7SEGDEC.sv"

class tests;
    environment env;
    virtual ahb7seg_if intf;

    function new(virtual ahb7seg_if intf);
        env = new(intf);
        this.intf = intf;
    endfunction

    task run();
        env.run();
    endtask

endclass