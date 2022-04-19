# basic bash script to run vlog compilation and vsim simulation in Questa Sim
# ssh -X mlg18@ee-mill3.ee.ic.ac.uk
# password: pupitre3tricot!
# source /usr/local/mentor/QUESTA-CORE-PRIME_10.7c/settings.sh

# run ./questasim_run.sh without argument to normal simulation
# run ./questasim_run.sh -c (with argument) for coverage report
vlib work

if [  -z $1 ] 
then 
vlog -work work +acc=blnr -noincr -timescale 1ns/1ps testbench/unit_level/UPDOWNSTREAM/tb_top_UPDOWNSTREAM.sv code/shared/top.sv
vopt -work work tb_top_UPDOWNSTREAM  -o seg_work_opt
vsim seg_work_opt -c -logfile testbench/outputs/top/UPDOWNSTREAM_sim.txt  -do "run -all; quit"


else 
# run converage check on questasim
rm -r covhtmlreport_toplevel/
rm testbench/outputs/top/UPDOWNSTREAM_cov_report.txt
vlog -work work +acc=blnr -noincr -timescale 1ns/1ps testbench/unit_level/UPDOWNSTREAM/tb_top_UPDOWNSTREAM.sv code/shared/top.sv
vopt -work work tb_top_UPDOWNSTREAM  -o seg_work_opt
vsim -coverage seg_work_opt -c -logfile testbench/outputs/top/UPDOWNSTREAM_sim.txt  -do "run -all;  coverage report -file testbench/outputs/top/UPDOWNSTREAM_cov_report.txt -byfile -assert -directive -cvg -codeAll; coverage save -onexit -assert -directive -cvg -codeAll testbench/outputs/top/updown.ucdb; quit"

# vsim -coverage seg_work_opt -gui -do "run -all; run 1500ns" 

vcover report -details -html testbench/outputs/top/updown.ucdb

# firefox covhtmlreport_toplevel/index.html
fi

# Command for top-level testing
# vlog -work work +acc=blnr -noincr -timescale 1ns/1ps  -f testbench/ahblite_sys.vc
# vopt -work work ahblite_sys_tb -o top_work_opt
# vsim top_work_opt -gui -do "log -r /*; add wave *; run 1500ns" 