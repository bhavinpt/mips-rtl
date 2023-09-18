#!/bin/csh

source /apps/design_environment.csh
vcs +v2k -sverilog tb.sv #$argv[*]
./simv +ntb_random_seed_automatic | tee log

echo ""
echo ""
echo ""
echo "output extract: "
echo ""
grep 'written R1' log
echo ""
echo ""
