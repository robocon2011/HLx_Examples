#!/bin/sh
################################################################################
# Author: Lisa Liu
# Date:	2016/11/07
#
# Usage:
#			./build_system.sh
# Vivado_hls version:
#			2015.1
# Vivado version:
#			2016.2
################################################################################


HLS_2015_1="/proj/xbuilds/2015.1_daily_latest/installs/lin64/SDK/2015.1/settings64.sh"
VIVADO_2016_2 = "/proj/xbuilds/2016.2_daily_latest/installs/lin64/SDK/2016.2/settings64.sh"

./build_hls_2015_1.sh "$HLS_2015_1"
source "$VIVADO_2016_2"
vivado -mode tcl -source create_prj.tcl
