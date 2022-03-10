# basic bash script to run vlog compilation and vsim simulation in Questa Sim
# source /usr/local/mentor/QUESTA-CORE-PRIME_10.7c/settings.sh

# run ./questasim_run.sh without argument to normal simulation
# run ./questasim_run.sh -c (with argument) for coverage report
vlib work

if [  -z $1 ] 
then 
vlog -work work +acc=blnr -noincr -timescale 1ns/1ps testbench/unit_level/DOWNSTREAM/tb_top_DOWNSTREAM.sv code/downstream/downstream_top.sv
vopt -work work tb_top_DOWNSTREAM  -o seg_work_opt
vsim seg_work_opt -c -logfile testbench/outputs/downstream/DOWNSTREAM_sim.txt  -do "run -all; quit"


else 
# run converage check on questasim
rm -r covhtmlreport/
rm testbench/outputs/downstream/DOWNSTREAM_cov_report.txt
vlog -work work +acc=blnr -noincr -timescale 1ns/1ps testbench/unit_level/DOWNSTREAM/tb_top_DOWNSTREAM.sv code/downstream/downstream_top.sv
vopt -work work tb_top_DOWNSTREAM  -o seg_work_opt
vsim -coverage seg_work_opt -c -logfile testbench/outputs/downstream/DOWNSTREAMnoreset_sim.txt  -do "run -all; coverage report -file testbench/outputs/downstream/DOWNSTREAMnoreset_cov_report.txt -byfile -assert -directive -cvg -codeAll; coverage save -onexit -assert -directive -cvg -codeAll testbench/outputs/downstream/downstream.ucdb; quit"

# vsim -coverage seg_work_opt -gui 

vcover report -details -html testbench/outputs/downstream/downstream.ucdb

# firefox covhtmlreport/index.html
fi

# Command for top-level testing
# vlog -work work +acc=blnr -noincr -timescale 1ns/1ps  -f testbench/ahblite_sys.vc
# vopt -work work ahblite_sys_tb -o top_work_opt
# vsim top_work_opt -gui -do "log -r /*; add wave *; run 1500ns" 