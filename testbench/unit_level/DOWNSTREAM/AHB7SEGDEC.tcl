# Script for multiplier example in JasperGold
clear -all
analyze -clear
analyze -sv AHB_peripherals_files/rtl/AHB_7SEG/AHB7SEGDEC.sv
elaborate -bbox_mul 64 -top AHB7SEGDEC

# Setup global clocks and resets
clock HCLK
reset -expression !(HRESETn)

# Setup task
task -set <embedded>
set_proofgrid_max_jobs 4
set_proofgrid_max_local_jobs 4
