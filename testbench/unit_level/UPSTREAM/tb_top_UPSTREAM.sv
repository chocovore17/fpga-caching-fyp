`include "interface_UPSTREAM.sv" // interface of gpio
`include "tests_UPSTREAM.sv" // a range of tests of gpio

module tb_top_UPSTREAM;
    //clock and reset signal declaration
    bit clk;
    bit slowclk;
    //creatinng instance of 7seg interface, inorder to connect DUT and testcase
    upstream_if intf(clk, slowclk);

    // Instantiate device under test
    upstream_processor_top UPSTREAM(
        // general inputs
        .clk(clk),
        .client_id(intf.client_id),
        .amount(intf.amount),
        .new_order(intf.new_order),
        .new_max(intf.new_max),
        // general outputs 
        .thenewmax(intf.thenewmax),
        .accumulated_orders(intf.accumulated_orders),
        .max_to_trade(intf.max_to_trade)
	);
    tests test;

    //functional coverage point to check range of input signal to DUT
    covergroup cg_input  @(posedge intf.slowclk);
        // reset_check: coverpoint intf.HRESETn{
        //     bins reset_trigger = {1'b0, 1'b1};
        // }
        // upstream_orders_valid: coverpoint intf.accumulated_orders {
        //     bins valid_data = [32'b0:(intf.amount + intf.max_to_trade)]; //accumulated order greater than amount to trade
        // }
        // valid_numerical_data: coverpoint intf.amount{
        //     bins dot = {16'h0001,16'h0000};
        // }
        // upstream_not_max: coverpoint intf.new_order{
        //     bins not_max = {1'b1}; //for now, extra test
        // }
        upstream_new_maxcheck: coverpoint intf.new_max{
            bins new_maxcheck = {1'b0,1'b1};
        }
        // upstream_hsel: coverpoint intf.HSEL{
        //     bins hselect = {1'b0,1'b1};
        // }
      
        upstream_maxcheck: coverpoint intf.thenewmax{
            bins maxcheck = {1'b0, intf.new_max}; //-> ^accumulated_orders = 1'b0; // even 
        }
    endgroup

    //functional coverage point to check range of output signal from DUT
    covergroup cg_output @(posedge intf.slowclk);
        upstream_rdata: coverpoint intf.max_to_trade[15:0]{ // equals to gpio_datain
            bins upstream_rdata =  {[0:64]};
        }
        // gpio_parity: coverpoint intf.PARITYERR{
        //     bins digital_point = {1'b0, 1'b1}; //should be no error
        // }

    endgroup

    cg_input cov_input;
    cg_output cov_output;

    //clock generation
    initial begin
        clk = 1'b0;
        slowclk = 1'b0;
        forever begin
            #2 clk = ~clk;
            #10 slowclk = ~slowclk;
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


