# basic bash script to run vlog compilation and vsim simulation in Questa Sim
# source /usr/local/mentor/QUESTA-CORE-PRIME_10.7c/settings.sh

# run ./questasim_run.sh without argument to normal simulation
# run ./questasim_run.sh -c (with argument) for coverage report
vlib work

if [  -z $1 ] 
then 
vlog -work work +acc=blnr -noincr -timescale 1ns/1ps testbench/unit_level/UPSTREAM/tb_top_UPSTREAM.sv code/upstream/upstream_top.sv
vopt -work work tb_top_UPSTREAM  -o seg_work_opt
vsim seg_work_opt -c -logfile testbench/outputs/upstream/UPSTREAM_sim.txt  -do "run -all; quit"


else 
# run converage check on questasim
rm -r covhtmlreport/
rm testbench/outputs/upstream/UPSTREAM_cov_report.txt
vlog -work work +acc=blnr -noincr -timescale 1ns/1ps testbench/unit_level/UPSTREAM/tb_top_UPSTREAM.sv code/upstream/upstream_top.sv
vopt -work work tb_top_UPSTREAM  -o seg_work_opt
vsim -coverage seg_work_opt -c -logfile testbench/outputs/upstream/UPSTREAM_sim.txt  -do "run -all; coverage report -file testbench/outputs/upstream/UPSTREAM_cov_report.txt -byfile -assert -directive -cvg -codeAll; coverage save -onexit -assert -directive -cvg -codeAll testbench/outputs/upstream/upstream.ucdb; quit"

# vsim -coverage seg_work_opt -gui 

vcover report -details -html testbench/outputs/upstream/upstream.ucdb

# firefox covhtmlreport/index.html
fi

# Command for top-level testing
# vlog -work work +acc=blnr -noincr -timescale 1ns/1ps  -f testbench/ahblite_sys.vc
# vopt -work work ahblite_sys_tb -o top_work_opt
# vsim top_work_opt -gui -do "log -r /*; add wave *; run 1500ns" 