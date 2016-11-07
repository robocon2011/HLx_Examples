open_project networkExtractor_prj

set_top networkExtractor

add_files ../src/hls/networkExtractor/networkExtractor.cpp

open_solution "solution1"
set_part {xc7vx690tffg1761-2}
create_clock -period 6.66 -name default
config_rtl -reset all -reset_async

csynth_design
export_design -format ip_catalog -display_name "Network Extractor" -description "Parses an ETH/IP/UDP header stack, removes it and stores the relevant fields in a metadata field" -vendor "xilinx.labs" -version "1.20"
exit
s
