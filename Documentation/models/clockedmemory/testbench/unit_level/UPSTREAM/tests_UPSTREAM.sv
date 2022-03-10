`include "environment_UPSTREAM.sv"

class tests;
    environment env;
    virtual upstream_if intf;

    function new(virtual upstream_if intf);
        env = new(intf);
        this.intf = intf;
    endfunction

    task run();
        env.run();
    endtask

endclass