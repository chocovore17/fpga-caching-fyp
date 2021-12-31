`include "interface_AHB7SEGDEC.sv" // interface of 7seg display
`include "tests_AHB7SEGDEC.sv" // a range of tests of 7seg display

module tb_top_AHB7SEGDEC;
    //clock and reset signal declaration
    bit clk;

    //creatinng instance of 7seg interface, inorder to connect DUT and testcase
    ahb7seg_if intf(clk);

    // Instantiate device under test
    AHB7SEGDEC DUT_7SEG(
        .HCLK(clk),
        .HRESETn(intf.HRESETn),
        .HADDR(intf.HADDR),
        .HWDATA(intf.HWDATA),
        .HTRANS(intf.HTRANS),
        .HWRITE(intf.HWRITE),
        .HSEL(intf.HSEL),
        .HREADY(intf.HREADY),
        .HRDATA(intf.HRDATA),
        .HREADYOUT(intf.HREADYOUT),
        .seg(intf.seg),
        .an(intf.an),
        .dp(intf.dp),
        .DLS_ERROR(intf.DLS_ERROR)
	);
    tests test;

    //functional coverage point to check range of input signal to DUT
    covergroup cg_input  @(posedge intf.clk);
        reset_check: coverpoint intf.HRESETn{
            bins reset_trigger = {1'b0, 1'b1};
        }
        valid_address_selection: coverpoint intf.HADDR {
            bins valid_addr_1 = {0};
            bins valid_addr_2 = {4};
            bins valid_addr_3 = {8};
            bins valid_addr_4 = {12};
        }
        valid_numerical_range: coverpoint intf.HWDATA[6:0] {
            bins valid_data = {[0:15]};
            // bins reserve = default;
        }
        digit_dot: coverpoint intf.HWDATA[7]{
            bins dot = {1'b0,1'b1};
        }
        ahb_trans: coverpoint intf.HTRANS[1]{
            bins htrans_en = {1'b0,1'b1};
        }
        ahb_hwrite: coverpoint intf.HWRITE{
            bins hwrite = {1'b0,1'b1};
        }
        ahb_hsel: coverpoint intf.HSEL{
            bins hselect = {1'b0,1'b1};
        }
        ahb_hready: coverpoint intf.HREADY{
            bins hready = {1'b0,1'b1};
        }
    endgroup

    //functional coverage point to check range of output signal from DUT
    covergroup cg_output @(posedge intf.clk);
        ahb_rdata: coverpoint intf.HRDATA[7:0]{
            bins valid_digit_range = {[0:15]};
            bins digit_0 = {0};
            bins digit_1 = {1};
            bins digit_2 = {2};
            bins digit_3 = {3};
            bins digit_4 = {4};
            bins digit_5 = {5};
            bins digit_6 = {6};
            bins digit_7 = {7};
            bins digit_8 = {8};
            bins digit_9 = {9};
            bins digit_a = {10};
            bins digit_b = {11};
            bins digit_c = {12};
            bins digit_d = {13};
            bins digit_e = {14};
            bins digit_f = {15};
        }
        seven_segment: coverpoint intf.seg{
            bins seg_0 = {~7'b0111111};
            bins seg_1 = {~7'b0000110};
            bins seg_2 = {~7'b1011011};
            bins seg_3 = {~7'b1001111};
            bins seg_4 = {~7'b1100110};
            bins seg_5 = {~7'b1101101};
            bins seg_6 = {~7'b1111101};
            bins seg_7 = {~7'b0000111};
            bins seg_8 = {~7'b1111111};
            bins seg_9 = {~7'b1101111};
            bins seg_a = {~7'b1110111};
            bins seg_b = {~7'b1111100};
            bins seg_c = {~7'b1011000};
            bins seg_d = {~7'b1011110};
            bins seg_e = {~7'b1111001};
            bins seg_f = {~7'b1110001};
            bins seg_reseve = default;
        }
        seg_an: coverpoint intf.an{
            bins ring_1 = {~4'b0001};
            bins ring_2 = {~4'b0010};
            bins ring_3 = {~4'b0100};
            bins ring_4 = {~4'b1000};
            bins seg_an_reserve = default;
        }
        seg_dp: coverpoint intf.dp{
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
        // reset at the beginning
        intf.HRESETn = 1'b0;
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
        $dumpfile("AHB_peripherals_files/tbench/tbenchoutputs/7seg/7seg_dump.vcd"); 
        $dumpvars; //specify vcd wave dump location
    end
endmodule


