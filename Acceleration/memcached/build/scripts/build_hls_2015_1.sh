#!/bin/sh
################################################################################
# Author: Lisa Liu
# Date:	2016/11/07
#
# Usage:
#			./build_hls_2015_1.sh
# Vivado_hls version:
#			2015.1
################################################################################
##cadman add -t xilinx -v 2015.1 -p vivado_gsd
##create ./run folder to store all intermediate results

source "$1"

BUILDDIR="$PWD"

echo "BUILDDIR is $BUILDDIR"

#eval cp ../scripts/tcl/*.tcl ./

eval vivado_hls -f run_hls.memcachedPipeline.tcl
eval vivado_hls -f run_hls.readConverter.tcl
eval vivado_hls -f run_hls.writeConverter.tcl
eval vivado_hls -f run_hls.ethInConverter.tcl
eval vivado_hls -f run_hls.ethOutConverter.tcl
eval vivado_hls -f run_hls.networkExtractor.tcl
eval vivado_hls -f run_hls.networkCompose.tcl

echo "Finished kvs HLS kernel synthesis"
