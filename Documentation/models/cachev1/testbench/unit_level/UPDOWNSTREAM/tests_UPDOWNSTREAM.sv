`include "environment_UPDOWNSTREAM.sv"

class tests;
    environment env;
    virtual updownstream_if intf;

    function new(virtual updownstream_if intf);
        env = new(intf);
        this.intf = intf;
    endfunction

    task run();
        env.run();
    endtask

endclass