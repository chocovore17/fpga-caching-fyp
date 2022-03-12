`include "environment_DOWNSTREAM.sv"

class tests;
    environment env;
    virtual dwnstrmproc_if intf;

    function new(virtual dwnstrmproc_if intf);
        env = new(intf);
        this.intf = intf;
    endfunction

    task run();
        env.run();
    endtask

endclass