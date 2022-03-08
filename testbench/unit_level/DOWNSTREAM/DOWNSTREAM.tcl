# Script for multiplier example in JasperGold
clear -all
analyze -clear
analyze -sv ..\..\..\code\downstream\downstream_top.sv
elaborate -bbox_mul 64 -top DOWNSTREAM

# Setup global clocks and resets
clock clk
reset -expression !(HRESETn)

# Setup task
task -set <embedded>
set_proofgrid_max_jobs 4
set_proofgrid_max_local_jobs 4
