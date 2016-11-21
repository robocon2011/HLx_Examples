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
VIVADO_USED="/proj/xbuilds/2015.3_daily_latest/installs/lin64/SDK/2015.3/settings64.sh"
VIVADO_2015_3="/proj/xbuilds/2015.3_daily_latest/installs/lin64/SDK/2015.3/settings64.sh"
VIVADO_2015_4="/proj/xbuilds/2015.4_daily_latest/installs/lin64/SDK/2015.4/settings64.sh"
VIVADO_2016_1="/proj/xbuilds/2016.1_daily_latest/installs/lin64/SDK/2016.1/settings64.sh"
VIVADO_2016_2="/proj/xbuilds/2016.2_daily_latest/installs/lin64/SDK/2016.2/settings64.sh"
VIVADO_2016_3="/proj/xbuilds/2016.3_daily_latest/installs/lin64/SDK/2016.3/settings64.sh"

./build_hls_2015_1.sh "$HLS_2015_1"
./build_tcp_ip_2015_1.sh "$HLS_2015_1"
source "$VIVADO_2015_3"
vivado -mode tcl -source create_prj_2015_3.tcl

source "$VIVADO_2015_4"
vivado -mode tcl -source create_prj_2015_4.tcl

source "$VIVADO_2016_1"
vivado -mode tcl -source create_prj_2016_1.tcl

source "$VIVADO_2016_2"
vivado -mode tcl -source create_prj_2016_2.tcl

source "$VIVADO_2016_3"
vivado -mode tcl -source create_prj_2016_3.tcl

exit 0
