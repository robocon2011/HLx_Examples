open_project ethInConverter_prj

set_top ethInConverter

add_files ../src/hls/ethInConverter/ethInConverter.cpp
open_solution "solution1"
set_part {xc7vx690tffg1761-2}
create_clock -period 6.66 -name default
config_rtl -reset all -reset_async

csynth_design
export_design -format ip_catalog -display_name "Ingress I/F Converter" -description "Converts AXI4S I/F to the Maxeler I/O used by the memcached pipeline" -vendor "xilinx.labs" -version "1.02"
exit
