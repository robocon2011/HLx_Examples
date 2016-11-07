open_project networkComposer_prj

set_top networkComposer

add_files ../src/hls/networkComposer/networkComposer.cpp

open_solution "solution1"
set_part {xc7vx690tffg1761-2}
create_clock -period 6.66 -name default
config_rtl -reset all -reset_async

csynth_design
export_design -format ip_catalog -display_name "Network Composer" -description "Creates an ETH/IP/UDP header stack from the provided metadata information" -vendor "xilinx.labs" -version "1.30"
exit
s
