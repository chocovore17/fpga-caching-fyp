`include "interface_DOWNSTREAM.sv" // interface of 7seg display
`include "tests_DOWNSTREAM.sv" // a range of tests of 7seg display

module tb_top_DOWNSTREAM;
    //clock and reset signal declaration
    bit clk;

    //creatinng instance of 7seg interface, inorder to connect DUT and testcase
    dwnstrmproc_if intf(clk);

    // Instantiate device under test
    downstream_top DOWNSTREAM(
        .clk(clk),
        .client_id(intf.client_id),
        .amount(intf.amount),
        .cancelled_orders(intf.cancelled_orders),
        .memwr(intf.memwr)
	);
    tests test;

    //functional coverage point to check range of input signal to DUT
    covergroup cg_input  @(posedge intf.clk);
    
        valid_address_selection: coverpoint intf.client_id {
            bins valid_addr_1 = {[0:15]};
        }
        valid_numerical_range: coverpoint intf.amount {
            bins valid_data = {[0:3000]};
            // bins reserve = default;
        }
    endgroup

    //functional coverage point to check range of output signal from DUT
    covergroup cg_output @(posedge intf.clk);
        seven_segment: coverpoint intf.cancelled_orders{
            bins valid_cancel = {[0:3000]};
        }
        seg_dp: coverpoint intf.memwr{
            bins digital_point = {1'b0,1'b1};
        }

    endgroup

    cg_input cov_input;
    cg_output cov_output;

    //clock generation
    initial begin
        clk = 1'b0;
        forever #5 clk = !clk;
    end

    initial begin
        // reset at the beginning needed ?
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
        $dumpfile("testbench/tbenchoutputs/downstream/downstreamdump.vcd"); 
        $dumpvars; //specify vcd wave dump location
    end
endmodule


