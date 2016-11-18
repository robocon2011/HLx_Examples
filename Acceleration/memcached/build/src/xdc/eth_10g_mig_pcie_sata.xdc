

##GT Ref clk differential pair for 10gig eth.  MGTREFCLK0P_116
create_clock -period 6.400 -name xgemac_clk_156 [get_ports xphy_refclk_p]
set_property PACKAGE_PIN T6 [get_ports xphy_refclk_p]
set_property PACKAGE_PIN T5 [get_ports xphy_refclk_n]

set_property PACKAGE_PIN U3 [get_ports xphy0_rxn]
set_property PACKAGE_PIN U4 [get_ports xphy0_rxp]
set_property PACKAGE_PIN T1 [get_ports xphy0_txn]
set_property PACKAGE_PIN T2 [get_ports xphy0_txp]

# SFP TX Disable for 10G PHY. Chip package 1157 on alpha data board only breaks out 2 transceivers!
set_property PACKAGE_PIN AC34 [get_ports {sfp_tx_disable[0]}]
set_property IOSTANDARD LVCMOS18 [get_ports {sfp_tx_disable[0]}]
set_property PACKAGE_PIN AA34 [get_ports {sfp_tx_disable[1]}]
set_property IOSTANDARD LVCMOS18 [get_ports {sfp_tx_disable[1]}]

set_property PACKAGE_PIN AA23 [get_ports sfp_on]
set_property IOSTANDARD LVCMOS18 [get_ports sfp_on]

create_clock -period 6.400 -name clk156 [get_pins n10g_interface_inst/xgbaser_gt_wrapper_inst/clk156_bufg_inst/O]
create_clock -period 12.800 -name dclk [get_pins n10g_interface_inst/xgbaser_gt_wrapper_inst/dclk_bufg_inst/O]
create_clock -period 6.400 -name refclk [get_pins n10g_interface_inst/xgphy_refclk_ibuf/O]

set_clock_groups -name async_xgemac_drpclk -asynchronous -group [get_clocks -include_generated_clocks clk156] -group [get_clocks -include_generated_clocks dclk]

#set_clock_groups -name async_ref_gmacTx -asynchronous #   -group [get_clocks clk156] #   -group [get_clocks n10g_interface_inst/network_inst_0/ten_gig_eth_pcs_pma_inst/inst/gt0_gtwizard_10gbaser_multi_gt_i/gt0_gtwizard_gth_10gbaser_i/gthe2_i/TXOUTCLK]

set_false_path -from [get_cells {n10g_interface_inst/xgbaser_gt_wrapper_inst/reset_pulse_reg[0]}]

set_clock_groups -name async_clk15_pll_i -asynchronous -group [get_clocks clk_pll_i] -group [get_clocks clk156]

#set_clock_groups -name async_clk156_pll_i_1 -asynchronous #     -group [get_clocks clk_pll_i_1] #     -group [get_clocks clk156]

#set_clock_groups -name clk156_clk100 -asynchronous -group [get_clocks clk100] -group [get_clocks clk156]

set_clock_groups -name clk156_pll_i_1 -asynchronous -group [get_clocks clk_pll_i_1] -group [get_clocks clk156]

#only really needed when stats are used, should be replaced by a false path anyway
#set_clock_groups -name async_pcie_clk -asynchronous -group [get_clocks -include_generated_clocks userclk1]
create_clock -period 10.000 -name clk100 [get_ports sysclk_in_p]

#set_property VCCAUX_IO DONTCARE [get_ports CLKBN]
set_property IOSTANDARD DIFF_SSTL15 [get_ports sysclk_in_n]
set_property PACKAGE_PIN AE31 [get_ports sysclk_in_p]
set_property PACKAGE_PIN AF31 [get_ports sysclk_in_n]

#set_property PACKAGE_PIN Y2 [get_ports sata1_tx_p]
#set_property PACKAGE_PIN Y1 [get_ports sata1_tx_n]
#set_property PACKAGE_PIN AA4 [get_ports sata1_rx_p]
#set_property PACKAGE_PIN AA3 [get_ports sata1_rx_n]


################################# RefClk Location constraints #####################
set_property PACKAGE_PIN V6 [get_ports q6_clk1_gtrefclk_pad_p_in]
set_property PACKAGE_PIN V5 [get_ports q6_clk1_gtrefclk_pad_n_in]

################################# mgt wrapper constraints #####################

##---------- Set placement for gt0_gth_wrapper_i/GTHE2_CHANNEL and other clock bufs ------
set_property LOC GTHE2_CHANNEL_X1Y24 [get_cells sata_gth_inst/sata3_gth_inst/inst/sata3_gth_ip_init_i/sata3_gth_ip_i/gt0_sata3_gth_ip_i/gthe2_i]
################################## Clock Constraints ##########################

#create_clock -name drpclk_in_i -period 10.0 [get_pins -hier -filter {name=~*gt_usrclk_source*DRP_CLK_BUFG*I}]
# User Clock Constraints
create_clock -period 6.667 -name gt0_txusrclk_i [get_pins -hier -filter name=~*gt0_sata3_gth_ip_i*gthe2_i*TXOUTCLK]
create_clock -period 6.667 -name gt0_rxusrclk_i [get_pins -hier -filter name=~*gt0_sata3_gth_ip_i*gthe2_i*RXOUTCLK]

set_false_path -from [get_clocks clk156] -to [get_clocks -include_generated_clocks userclk1]
set_false_path -from [get_clocks -include_generated_clocks userclk1] -to [get_clocks clk156]

#only needed when sata is used
set_false_path -from [get_clocks clk100] -to [get_clocks -include_generated_clocks gt0_rxusrclk_i]
set_false_path -from [get_clocks -include_generated_clocks gt0_rxusrclk_i] -to [get_clocks clk100]

set_false_path -from [get_clocks clk156] -to [get_clocks -include_generated_clocks gt0_rxusrclk_i]
set_false_path -from [get_clocks -include_generated_clocks gt0_rxusrclk_i] -to [get_clocks clk156]

set_false_path -from [get_clocks clk100] -to [get_clocks -include_generated_clocks gt0_txusrclk_i]
set_false_path -from [get_clocks -include_generated_clocks gt0_txusrclk_i] -to [get_clocks clk100]