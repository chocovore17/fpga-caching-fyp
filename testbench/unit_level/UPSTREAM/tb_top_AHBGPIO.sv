`include "interface_AHBGPIO.sv" // interface of gpio
`include "tests_AHBGPIO.sv" // a range of tests of gpio

module tb_top_AHBGPIO;
    //clock and reset signal declaration
    bit clk;

    //creatinng instance of 7seg interface, inorder to connect DUT and testcase
    ahbgpio_if intf(clk);

    // Instantiate device under test
    AHBGPIO DUT_GPIO(
        // general inputs
        .HCLK(clk),
        .HRESETn(intf.HRESETn),
        .HADDR(intf.HADDR),
        .HWDATA(intf.HWDATA),
        .HTRANS(intf.HTRANS),
        .HWRITE(intf.HWRITE),
        .HSEL(intf.HSEL),
        .HREADY(intf.HREADY),
        // gpio inputs 
        .PARITYSEL(intf.PARITYSEL),
        .GPIOIN(intf.GPIOIN),
        //general outputs
        .HRDATA(intf.HRDATA),
        .HREADYOUT(intf.HREADYOUT),
        // gpio outputs
        .GPIOOUT(intf.GPIOOUT),
        .PARITYERR(intf.PARITYERR)
	);
    tests test;

    //functional coverage point to check range of input signal to DUT
    covergroup cg_input  @(posedge intf.clk);
        reset_check: coverpoint intf.HRESETn{
            bins reset_trigger = {1'b0, 1'b1};
        }
        valid_address_selection: coverpoint intf.HADDR[7:0] {
            bins valid_addr_1 = {0};
            bins valid_addr_2 = {4};
            bins valid_addr_3 = {8};
            bins valid_addr_4 = {12};
        }
        ahb_gpioin_valid: coverpoint intf.GPIOIN[0] {
            bins valid_data = {^~intf.GPIOIN[16:1]};
        }
        valid_numerical_data: coverpoint intf.HWDATA[15:0]{
            bins dot = {16'h0001,16'h0000};
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
      
        ahb_paritysel: coverpoint intf.PARITYSEL{
            bins paritysel = {1'b0, 1'b1}; //-> ^GPIOIN = 1'b0; // even 
        }
    endgroup

    //functional coverage point to check range of output signal from DUT
    covergroup cg_output @(posedge intf.clk);
        ahb_rdata: coverpoint intf.HRDATA[15:0]{ // equals to gpio_datain
            bins valid_digit_range =  {[0:64]};
        }
        gpio_parity: coverpoint intf.PARITYERR{
            bins digital_point = {1'b0, 1'b1}; //should be no error
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
        // reset at the beginning and set to no errors
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
        $dumpfile("AHB_peripherals_files/tbench/tbenchoutputs/gpio/gpio_dump.vcd"); 
        $dumpvars; //specify vcd wave dump location
    end
endmodule


