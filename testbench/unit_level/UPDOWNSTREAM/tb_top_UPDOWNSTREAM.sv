`include "interface_UPDOWNSTREAM.sv" // interface of gpio
`include "tests_UPDOWNSTREAM.sv" // a range of tests of gpio

module tb_top_UPDOWNSTREAM;
    //clock and reset signal declaration
    bit clk;
    bit slowclk;
    //creatinng instance of 7seg interface, inorder to connect DUT and testcase
    updownstream_if intf(clk, slowclk);

    // Instantiate device under test
    top TOP(
        // general inputs
        .clk(clk),
        .HRESETn(intf.HRESETn),
        .cpu_client_id(intf.cpu_client_id),
        .cpu_amount(intf.cpu_amount),
        .cpu_go(intf.cpu_go),
        .cpu_new_max(intf.cpu_new_max),
        .exchange_client_id(intf.exchange_client_id),
        .exchange_amount(intf.exchange_amount),
        .exchange_go(intf.exchange_go),
        // general outputs 
        .accumulated_orders(intf.accumulated_orders),
        .cancelled_orders(intf.cancelled_orders),
        .max_to_trade(intf.max_to_trade)
	);
    tests test;

    //functional coverage point to check range of input signal to DUT
    covergroup cg_input  @(posedge intf.slowclk);
        reset_check: coverpoint intf.HRESETn{
            bins reset_trigger = {1'b0, 1'b1};
        }
        valid_client_id: coverpoint intf.cpu_client_id{
            bins client_id = {[0:10]};
        }
        // upstream_not_max: coverpoint intf.cpu_go{
        //     bins not_max = ~intf.cpu_new_max; //for now, extra test
        // }
        upstream_new_maxcheck: coverpoint intf.cpu_new_max{
            bins new_maxcheck = {1'b0,1'b1};
        }
        downstream_exchchangecheck: coverpoint intf.exchange_go{
            bins exchange_go = {1'b0,1'b1};
        }
      
    endgroup

    //functional coverage point to check range of output signal from DUT
    covergroup cg_output @(posedge intf.slowclk);
        upstream_acc_data: coverpoint intf.accumulated_orders[15:0]{ // equals to gpio_datain
            bins accumulated_orders =  {[0:64]};
        }
        upstream_max_data: coverpoint intf.max_to_trade[15:0]{ // equals to gpio_datain
            bins max_to_trade  =  {[0:65450]};
        }
        downstream_cxl_data: coverpoint intf.cancelled_orders[15:0]{ // equals to gpio_datain
            bins cancelled_orders  =  {[0:64]};
        }

    endgroup

    cg_input cov_input;
    cg_output cov_output;

    //clock generation
    initial begin
        clk = 1'b0;
        slowclk = 1'b0;
        forever begin
            #2 clk = ~clk;
            #4 slowclk = ~slowclk;
        // forever #5 clk = !clk;
        end
    end

    initial begin
        // reset at the beginning and set to no errors
        // intf.HRESETn = 1'b0;
        //instantiate test 
        test = new(intf);
        
        // instantiate covergroup
        cov_input = new();
        cov_output = new();

        test.run();

        $display("Coverage_input = %0.2f %%", cov_input.get_inst_coverage());
        $display("Coverage_output = %0.2f %%", cov_output.get_inst_coverage());
        #20 $stop;
    end

    initial begin 
        $dumpfile("testbench/tbenchoutputs/upstream/upstreamdump.vcd"); 
        $dumpvars; //specify vcd wave dump location
    end
endmodule


