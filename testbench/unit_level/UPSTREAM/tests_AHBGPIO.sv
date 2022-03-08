`include "environment_AHBGPIO.sv"

class tests;
    environment env;
    virtual ahbgpio_if intf;

    function new(virtual ahbgpio_if intf);
        env = new(intf);
        this.intf = intf;
    endfunction

    task run();
        env.run();
    endtask

endclass