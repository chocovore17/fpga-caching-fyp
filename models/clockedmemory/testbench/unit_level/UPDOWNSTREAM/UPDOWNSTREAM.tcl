# Script for multiplier example in JasperGold
clear -all
analyze -clear
analyze -sv ..\..\..\code\upstream\upstream_top.sv
elaborate -bbox_mul 64 -top UPSTREAM

# Setup global clocks and resets
clock HCLK
reset -expression !(HRESETn)

# Setup task
task -set <embedded>
set_proofgrid_max_jobs 4
set_proofgrid_max_local_jobs 4
