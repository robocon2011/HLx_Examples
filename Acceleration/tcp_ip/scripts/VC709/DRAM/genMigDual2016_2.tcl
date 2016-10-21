set module_name {mig_axi_mm_dual}
create_ip -name mig_7series -vendor xilinx.com -library ip -version 4.0 -module_name ${module_name}
set_property -dict [list CONFIG.XML_INPUT_FILE {mig_a.prj} CONFIG.RESET_BOARD_INTERFACE {Custom} CONFIG.MIG_DONT_TOUCH_PARAM {Custom} CONFIG.BOARD_MIG_PARAM {Custom}] [get_ips ${module_name}]
generate_target {instantiation_template} [get_files ${module_name}.xci]
update_compile_order -fileset sources_1
