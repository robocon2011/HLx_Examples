open_project ethOutConverter_prj

set_top ethOutConverter

add_files sources/otherModules/ethOutConverter/ethOutConverter.cpp

open_solution "solution1"
set_part {xc7vx690tffg1761-2}
create_clock -period 6.66 -name default
config_rtl -reset all -reset_async

csynth_design
export_design -format ip_catalog -display_name "Egress I/F Converter" -description "Converts the Maxeler I/O used by the memcached pipeline to standard AXI4S I/F" -vendor "xilinx.labs" -version "1.01"
exit