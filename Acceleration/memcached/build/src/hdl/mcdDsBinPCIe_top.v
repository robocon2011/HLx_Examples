`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 03/18/2014 12:31:08 PM
// Design Name: 
// Module Name: top
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module mcdDsBinPCIe_top(
    input                          xphy_refclk_p,
    input                          xphy_refclk_n,
    
    output                         xphy0_txp,
    output                         xphy0_txn,
    input                          xphy0_rxp,
    input                          xphy0_rxn,
        
    output[1:0] sfp_tx_disable,
    //pcie ports
    input [7:0]pcie_7x_mgt_rxn,
    input [7:0]pcie_7x_mgt_rxp,
    output [7:0]pcie_7x_mgt_txn,
    output [7:0]pcie_7x_mgt_txp,
    input pcie_clkp,
    input pcie_clkn,
    input pcie_reset,
    // sata ports
    input         q6_clk1_gtrefclk_pad_p_in, // GTH reference clock input
    input         q6_clk1_gtrefclk_pad_n_in, // GTH reference clock input
    input         sysclk_in_p, //100MHz differential system clock
    input         sysclk_in_n,
    output sata1_tx_p,
    output sata1_tx_n,
    input sata1_rx_p,
    input sata1_rx_n,
    
    //dramp ports
   inout [71:0]                         c0_ddr3_dq,
   inout [8:0]                        c0_ddr3_dqs_n,
   inout [8:0]                        c0_ddr3_dqs_p,

   // Outputs
   output [15:0]                       c0_ddr3_addr,
   output [2:0]                      c0_ddr3_ba,
   output                                       c0_ddr3_ras_n,
   output                                       c0_ddr3_cas_n,
   output                                       c0_ddr3_we_n,
   output                                       c0_ddr3_reset_n,
   output [1:0]                        c0_ddr3_ck_p,
   output [1:0]                        c0_ddr3_ck_n,
   output [1:0]                       c0_ddr3_cke,
   output [1:0]           c0_ddr3_cs_n,
   output [1:0]                       c0_ddr3_odt,

   // Inputs
   
   // Differential system clocks
   input                                        c0_sys_clk_p,
   input                                        c0_sys_clk_n,
   // differential iodelayctrl clk (reference clock)
   input                                        clk_ref_p,
   input                                        clk_ref_n,
      
   // Inouts
   inout [71:0]                         c1_ddr3_dq,
   inout [8:0]                        c1_ddr3_dqs_n,
   inout [8:0]                        c1_ddr3_dqs_p,

   // Outputs
   output [15:0]                       c1_ddr3_addr,
   output [2:0]                      c1_ddr3_ba,
   output                                       c1_ddr3_ras_n,
   output                                       c1_ddr3_cas_n,
   output                                       c1_ddr3_we_n,
   output                                       c1_ddr3_reset_n,
   output [1:0]                        c1_ddr3_ck_p,
   output [1:0]                        c1_ddr3_ck_n,
   output [1:0]                       c1_ddr3_cke,
   output [1:0]           c1_ddr3_cs_n,
   output [1:0]                       c1_ddr3_odt,

   // Inputs
   
   // Differential system clocks
   input                                        c1_sys_clk_p,
   input                                        c1_sys_clk_n,
   output [8:0] c0_ddr3_dm,
   output [8:0] c1_ddr3_dm,
   output sfp_on, 
   output [1:0] dram_on,
   input    pok_dram
);
//manually tie off ddr3_dm
    assign sfp_on = 1'b1;
    assign dram_on = 2'b11;
    assign c0_ddr3_dm = 9'b0;
    assign c1_ddr3_dm = 9'b0;
    
localparam DRAM_WIDTH = 512;
localparam FLASH_WIDTH = 64;
//localparam DRAM_CMD_WIDTH = 24;
localparam DRAM_CMD_WIDTH = 40;
localparam FLASH_CMD_WIDTH	= 48;
    
 wire network_init, axi_clk, aresetn;
    
 /***********************************
 * 10G Network Interface Module
 ***********************************/
wire        AXI_M_Stream_TVALID;
wire        AXI_M_Stream_TREADY;
wire[63:0]  AXI_M_Stream_TDATA;
wire[7:0]   AXI_M_Stream_TKEEP;
wire        AXI_M_Stream_TLAST;

wire        AXI_S_Stream_TVALID;
wire        AXI_S_Stream_TREADY;
wire[63:0]  AXI_S_Stream_TDATA;
wire[7:0]   AXI_S_Stream_TKEEP;
wire        AXI_S_Stream_TLAST;
//nic rx status info
wire        nic_rx_fifo_overflow;
wire [29:0]   nic_rx_statistics_vector;
wire          nic_rx_statistics_valid;


assign aresetn= network_init;

eth10g_interface  n10g_interface_inst(
    .reset(1'b0),
    .aresetn(aresetn),
    
    .xphy_refclk_p(xphy_refclk_p),
    .xphy_refclk_n(xphy_refclk_n),
    
    .xphy0_txp(xphy0_txp),
    .xphy0_txn(xphy0_txn),
    .xphy0_rxp(xphy0_rxp),
    .xphy0_rxn(xphy0_rxn),
    
    
    .axis_i_0_tdata(AXI_S_Stream_TDATA),
    .axis_i_0_tvalid(AXI_S_Stream_TVALID),
    .axis_i_0_tlast(AXI_S_Stream_TLAST),
    .axis_i_0_tuser(),
    .axis_i_0_tkeep(AXI_S_Stream_TKEEP),
    .axis_i_0_tready(AXI_S_Stream_TREADY),
    .nic_rx_fifo_overflow(nic_rx_fifo_overflow),
    .nic_rx_statistics_vector(nic_rx_statistics_vector),
    .nic_rx_statistics_valid(nic_rx_statistics_valid),   
    
    .axis_o_0_tdata(AXI_M_Stream_TDATA),
    .axis_o_0_tvalid(AXI_M_Stream_TVALID),
    .axis_o_0_tlast(AXI_M_Stream_TLAST),
    .axis_o_0_tuser(0),
    .axis_o_0_tkeep(AXI_M_Stream_TKEEP),
    .axis_o_0_tready(AXI_M_Stream_TREADY),
        
    .sfp_tx_disable(sfp_tx_disable),
    .clk156_out(axi_clk),
    .network_reset_done(network_init),
    .led()
    );


wire[183:0]     axis_inStream_tdata;         
wire            axis_inStream_tvalid;
wire            axis_inStream_tready;

wire[183:0]     axis_inExtractor_tdata;         
wire            axis_inExtractor_tvalid;
wire            axis_inExtractor_tready;



wire[183:0]     axis_outComposer_tdata;         
wire            axis_outComposer_tvalid;
wire            axis_outComposer_tready;


wire[71:0]     axis_outStream_tdata;         
wire            axis_outStream_tvalid;
wire            axis_outStream_tready;

ethinconverter_top ethInConverter_inst (
    .aclk(axi_clk),
    .aresetn(aresetn),
    .AXI4Stream_I_TVALID(AXI_S_Stream_TVALID),
    .AXI4Stream_I_TREADY(AXI_S_Stream_TREADY),
    .AXI4Stream_I_TDATA(AXI_S_Stream_TDATA),
    .AXI4Stream_I_TKEEP(AXI_S_Stream_TKEEP),
    .AXI4Stream_I_TLAST(AXI_S_Stream_TLAST),
    .outPacket_V_TVALID(axis_inStream_tvalid),
    .outPacket_V_TREADY(axis_inStream_tready),
    .outPacket_V_TDATA(axis_inStream_tdata)
);


// Network Extractor
networkextractor_top networkExtractor_inst (
    .inPacket_V_TVALID(axis_inStream_tvalid),
    .inPacket_V_TREADY(axis_inStream_tready),
    .inPacket_V_TDATA(axis_inStream_tdata),
    .outPacket_V_TVALID(axis_inExtractor_tvalid),
    .outPacket_V_TREADY(axis_inExtractor_tready),
    .outPacket_V_TDATA(axis_inExtractor_tdata),
    .aclk(axi_clk),
    .aresetn(aresetn));
    
wire [183:0] stats0_tdata;
wire stats0_tvalid;
wire stats0_tready;
wire [31:0] stats0;
//stats 0 sits between network extractor and pipeline
stats_module #(.data_size(184)) stats_module_i0( 
.ACLK(axi_clk),
.RESET(~aresetn),

.M_AXIS_TDATA(stats0_tdata), 
.M_AXIS_TVALID(stats0_tvalid),
.M_AXIS_TREADY(stats0_tready),

.S_AXIS_TDATA(axis_inExtractor_tdata),
.S_AXIS_TVALID(axis_inExtractor_tvalid),
.S_AXIS_TREADY(axis_inExtractor_tready),

.STATS_DATA(stats0)
);    

wire [183:0] stats1_tdata;
wire stats1_tvalid;
wire stats1_tready;
wire [31:0] stats1;
//stats1 sits between pipeline and composer
stats_module #(.data_size(184)) stats_module_i1( 
.ACLK(axi_clk),
.RESET(~aresetn),

.M_AXIS_TDATA(axis_outComposer_tdata), 
.M_AXIS_TVALID(axis_outComposer_tvalid),
.M_AXIS_TREADY(axis_outComposer_tready),

.S_AXIS_TDATA(stats1_tdata),
.S_AXIS_TVALID(stats1_tvalid),
.S_AXIS_TREADY(stats1_tready),

.STATS_DATA(stats1)
);
    
networkcomposer_top networkComposer_inst (
        .inPacket_V_TVALID(axis_outComposer_tvalid),
        .inPacket_V_TREADY(axis_outComposer_tready),
        .inPacket_V_TDATA(axis_outComposer_tdata),
        .outPacket_V_TVALID(axis_outStream_tvalid),
        .outPacket_V_TREADY(axis_outStream_tready),
        .outPacket_V_TDATA(axis_outStream_tdata),
        .aclk(axi_clk),
        .aresetn(aresetn));


//signals between mcd and dram
wire           c0_ui_clk;
wire           c0_init_calib_complete;
wire           c1_ui_clk;
wire           c1_init_calib_complete;

//ht stream interface signals
wire           ht_s_axis_read_cmd_tvalid;
wire          ht_s_axis_read_cmd_tready;
wire[71:0]     ht_s_axis_read_cmd_tdata;
//read status
wire          ht_m_axis_read_sts_tvalid;
wire           ht_m_axis_read_sts_tready;
wire[7:0]     ht_m_axis_read_sts_tdata;
//read stream
wire[511:0]    ht_m_axis_read_tdata;
wire[63:0]     ht_m_axis_read_tkeep;
wire          ht_m_axis_read_tlast;
wire          ht_m_axis_read_tvalid;
wire           ht_m_axis_read_tready;

//write commands
wire           ht_s_axis_write_cmd_tvalid;
wire          ht_s_axis_write_cmd_tready;
wire[71:0]     ht_s_axis_write_cmd_tdata;
//write status
wire          ht_m_axis_write_sts_tvalid;
wire           ht_m_axis_write_sts_tready;
wire[7:0]     ht_m_axis_write_sts_tdata;
//write stream
wire[511:0]     ht_s_axis_write_tdata;
wire[63:0]      ht_s_axis_write_tkeep;
wire           ht_s_axis_write_tlast;
wire           ht_s_axis_write_tvalid;
wire          ht_s_axis_write_tready;

//upd stream interface signals
wire           vs_s_axis_read_cmd_tvalid;
wire          vs_s_axis_read_cmd_tready;
wire[71:0]     vs_s_axis_read_cmd_tdata;
//read status
wire          vs_m_axis_read_sts_tvalid;
wire           vs_m_axis_read_sts_tready;
wire[7:0]     vs_m_axis_read_sts_tdata;
//read stream
wire[511:0]    vs_m_axis_read_tdata;
wire[63:0]     vs_m_axis_read_tkeep;
wire          vs_m_axis_read_tlast;
wire          vs_m_axis_read_tvalid;
wire           vs_m_axis_read_tready;

//write commands
wire           vs_s_axis_write_cmd_tvalid;
wire          vs_s_axis_write_cmd_tready;
wire[71:0]     vs_s_axis_write_cmd_tdata;
//write status
wire          vs_m_axis_write_sts_tvalid;
wire           vs_m_axis_write_sts_tready;
wire[7:0]     vs_m_axis_write_sts_tdata;
//write stream
wire[511:0]     vs_s_axis_write_tdata;
wire[63:0]      vs_s_axis_write_tkeep;
wire            vs_s_axis_write_tlast;
wire            vs_s_axis_write_tvalid;
wire           vs_s_axis_write_tready;

//pcie related signals
wire pcie_clk;
wire pcie_user_lnk_up;
  
wire [31: 0] pcie_axi_AWADDR;
wire pcie_axi_AWVALID;
wire pcie_axi_AWREADY;

wire [31: 0]   pcie_axi_WDATA;
wire [3: 0] pcie_axi_WSTRB;
wire pcie_axi_WVALID;
wire pcie_axi_WREADY;

wire [1:0] pcie_axi_BRESP;
wire pcie_axi_BVALID;
wire pcie_axi_BREADY;
     
wire [31: 0] pcie_axi_ARADDR;
wire pcie_axi_ARVALID;
wire pcie_axi_ARREADY;
     
wire [31: 0] pcie_axi_RDATA;
wire [1:0] pcie_axi_RRESP;
wire pcie_axi_RVALID;
wire  pcie_axi_RREADY;

//signals to/from sata gth
wire clk150;
wire gth_reset;
wire hard_reset;     // Active high, reset button pushed on board
wire soft_reset;     // Active high, user reset can be pulled any time
//gth outputs
// RX GTH tile <-> Link Module
wire           RXELECIDLE0;
wire [3:0]     RXCHARISK0;
wire [31:0]    RXDATA;
wire           RXBYTEISALIGNED0;
wire          gt0_rxbyterealign_out;
wire          gt0_rxcommadet_out;
        
// TX GTH tile <-> Link Module
wire           TXELECIDLE;
wire [31:0]    TXDATA;
wire           TXCHARISK;
              
wire rx_reset_done; 
wire tx_reset_done;
wire rx_comwake_det;
wire rx_cominit_det;
wire tx_cominit;
wire tx_comfinish; 
wire tx_comwake;
wire rx_start;
wire link_initialized_clk156;
wire ncq_idle_clk156;
wire fin_read_sig_clk156;

reg c1_init_calib_complete_r;

always @(posedge axi_clk)
    c1_init_calib_complete_r <= c1_init_calib_complete;

mcdDsBinPCIe #(
                .DRAM_WIDTH(DRAM_WIDTH),
                .FLASH_WIDTH(FLASH_WIDTH),
                .DRAM_CMD_WIDTH(DRAM_CMD_WIDTH),
                .FLASH_CMD_WIDTH(FLASH_CMD_WIDTH)
) memcached_inst(
    .clk(axi_clk),
    .aresetn(aresetn & c1_init_calib_complete_r),
    .udp_in_data(stats0_tdata),//(axis_inExtractor_tdata),
    .udp_in_ready(stats0_tready),//(axis_inExtractor_tready),
    .udp_in_valid(stats0_tvalid), //(axis_inExtractor_tvalid),
    
    .udp_out_data(stats1_tdata), //(axis_outComposer_tdata),
    .udp_out_ready(stats1_tready), //(axis_outComposer_tready),
    .udp_out_valid(stats1_tvalid), //(axis_outComposer_tvalid),
    .stats0(stats0),
    .stats1(stats1),
    //pcie interface
    .pcie_axi_AWADDR(pcie_axi_AWADDR),
    .pcie_axi_AWVALID(pcie_axi_AWVALID),
    .pcie_axi_AWREADY(pcie_axi_AWREADY),
    
    //data write
    .pcie_axi_WDATA(pcie_axi_WDATA),
    .pcie_axi_WSTRB(pcie_axi_WSTRB),
    .pcie_axi_WVALID(pcie_axi_WVALID),
    .pcie_axi_WREADY(pcie_axi_WREADY),
    
    //write response (handhake)
    .pcie_axi_BRESP(pcie_axi_BRESP),
    .pcie_axi_BVALID(pcie_axi_BVALID),
    .pcie_axi_BREADY(pcie_axi_BREADY),
    
    //address read
    .pcie_axi_ARADDR(pcie_axi_ARADDR),
    .pcie_axi_ARVALID(pcie_axi_ARVALID),
    .pcie_axi_ARREADY(pcie_axi_ARREADY),
    
    //data read
    .pcie_axi_RDATA(pcie_axi_RDATA),
    .pcie_axi_RRESP(pcie_axi_RRESP),
    .pcie_axi_RVALID(pcie_axi_RVALID),
    .pcie_axi_RREADY(pcie_axi_RREADY),
    .pcieClk(pcie_clk),
    .pcie_user_lnk_up(pcie_user_lnk_up),
    
    //sata gth signals
    .clk150(clk150),
    .gth_reset(gth_reset),
    .hard_reset(hard_reset),     // Active high, reset button pushed on board
    .soft_reset(soft_reset),     // Active high, user reset can be pulled any time
    //gth outputs
     // RX GTH tile <-> Link Module
    .RXELECIDLE0(RXELECIDLE0),
    .RXCHARISK0(RXCHARISK0),
    .RXDATA(RXDATA),
    .RXBYTEISALIGNED0(RXBYTEISALIGNED0),
    .gt0_rxbyterealign_out(gt0_rxbyterealign_out),
    .gt0_rxcommadet_out(gt0_rxcommadet_out),
    
     // TX GTH tile <-> Link Module
    .TXELECIDLE(TXELECIDLE),
    .TXDATA(TXDATA),
    .TXCHARISK(TXCHARISK),
          
    .rx_reset_done(rx_reset_done), 
    .tx_reset_done(tx_reset_done),
    .rx_comwake_det(rx_comwake_det),
    .rx_cominit_det(rx_cominit_det),
    .tx_cominit(tx_cominit), 
    .tx_comwake(tx_comwake),
    .rx_start(rx_start),
    .link_initialized_clk156(link_initialized_clk156),
    .ncq_idle_clk156(),
    .fin_read_sig_clk156(),
    
    //mem signals
    .ht_s_axis_read_cmd_tvalid(ht_s_axis_read_cmd_tvalid),
    .ht_s_axis_read_cmd_tready(ht_s_axis_read_cmd_tready),
    .ht_s_axis_read_cmd_tdata(ht_s_axis_read_cmd_tdata),
    //read status
    .ht_m_axis_read_sts_tvalid(ht_m_axis_read_sts_tvalid),
    .ht_m_axis_read_sts_tready(ht_m_axis_read_sts_tready),
    .ht_m_axis_read_sts_tdata(ht_m_axis_read_sts_tdata),
    //read stream
    .ht_m_axis_read_tdata(ht_m_axis_read_tdata),
    .ht_m_axis_read_tkeep(ht_m_axis_read_tkeep),
    .ht_m_axis_read_tlast(ht_m_axis_read_tlast),
    .ht_m_axis_read_tvalid(ht_m_axis_read_tvalid),
    .ht_m_axis_read_tready(ht_m_axis_read_tready),
    
    //write commands
    .ht_s_axis_write_cmd_tvalid(ht_s_axis_write_cmd_tvalid),
    .ht_s_axis_write_cmd_tready(ht_s_axis_write_cmd_tready),
    .ht_s_axis_write_cmd_tdata(ht_s_axis_write_cmd_tdata),
    //write status
    .ht_m_axis_write_sts_tvalid(ht_m_axis_write_sts_tvalid),
    .ht_m_axis_write_sts_tready(ht_m_axis_write_sts_tready),
    .ht_m_axis_write_sts_tdata(ht_m_axis_write_sts_tdata),
    //write stream
    .ht_s_axis_write_tdata(ht_s_axis_write_tdata),
    .ht_s_axis_write_tkeep(ht_s_axis_write_tkeep),
    .ht_s_axis_write_tlast(ht_s_axis_write_tlast),
    .ht_s_axis_write_tvalid(ht_s_axis_write_tvalid),
    .ht_s_axis_write_tready(ht_s_axis_write_tready),
    
    //vs stream interface signals
    .vs_s_axis_read_cmd_tvalid(vs_s_axis_read_cmd_tvalid),
    .vs_s_axis_read_cmd_tready(vs_s_axis_read_cmd_tready),
    .vs_s_axis_read_cmd_tdata(vs_s_axis_read_cmd_tdata),
    //read status
    .vs_m_axis_read_sts_tvalid(vs_m_axis_read_sts_tvalid),
    .vs_m_axis_read_sts_tready(vs_m_axis_read_sts_tready),
    .vs_m_axis_read_sts_tdata(vs_m_axis_read_sts_tdata),
    //read stream
    .vs_m_axis_read_tdata(vs_m_axis_read_tdata),
    .vs_m_axis_read_tkeep(vs_m_axis_read_tkeep),
    .vs_m_axis_read_tlast(vs_m_axis_read_tlast),
    .vs_m_axis_read_tvalid(vs_m_axis_read_tvalid),
    .vs_m_axis_read_tready(vs_m_axis_read_tready),
    
    //write commands
    .vs_s_axis_write_cmd_tvalid(vs_s_axis_write_cmd_tvalid),
    .vs_s_axis_write_cmd_tready(vs_s_axis_write_cmd_tready),
    .vs_s_axis_write_cmd_tdata(vs_s_axis_write_cmd_tdata),
    //write status
    .vs_m_axis_write_sts_tvalid(vs_m_axis_write_sts_tvalid),
    .vs_m_axis_write_sts_tready(vs_m_axis_write_sts_tready),
    .vs_m_axis_write_sts_tdata(vs_m_axis_write_sts_tdata),
    //write stream
    .vs_s_axis_write_tdata(vs_s_axis_write_tdata),
    .vs_s_axis_write_tkeep(vs_s_axis_write_tkeep),
    .vs_s_axis_write_tlast(vs_s_axis_write_tlast),
    .vs_s_axis_write_tvalid(vs_s_axis_write_tvalid),
    .vs_s_axis_write_tready(vs_s_axis_write_tready)  
);

pcie_bridge pcie_bridge_inst(
  .pcie_7x_mgt_rxn(pcie_7x_mgt_rxn),
  .pcie_7x_mgt_rxp(pcie_7x_mgt_rxp),
  .pcie_7x_mgt_txn(pcie_7x_mgt_txn),
  .pcie_7x_mgt_txp(pcie_7x_mgt_txp),
  .pcie_clkp(pcie_clkp), 
  .pcie_clkn(pcie_clkn),
  .pcie_reset(~pcie_reset),
  
  .clkOut(pcie_clk),
  .user_lnk_up(pcie_user_lnk_up),
  
  .pcie_axi_AWADDR(pcie_axi_AWADDR),
  .pcie_axi_AWVALID(pcie_axi_AWVALID),
  .pcie_axi_AWREADY(pcie_axi_AWREADY),
     
  .pcie_axi_WDATA(pcie_axi_WDATA),
  .pcie_axi_WSTRB(pcie_axi_WSTRB),
  .pcie_axi_WVALID(pcie_axi_WVALID),
  .pcie_axi_WREADY(pcie_axi_WREADY),
    
  .pcie_axi_BRESP(pcie_axi_BRESP),
  .pcie_axi_BVALID(pcie_axi_BVALID),
  .pcie_axi_BREADY(pcie_axi_BREADY),
     
  .pcie_axi_ARADDR(pcie_axi_ARADDR),
  .pcie_axi_ARVALID(pcie_axi_ARVALID),
  .pcie_axi_ARREADY(pcie_axi_ARREADY),
     
  .pcie_axi_RDATA(pcie_axi_RDATA),
  .pcie_axi_RRESP(pcie_axi_RRESP),
  .pcie_axi_RVALID(pcie_axi_RVALID),
  .pcie_axi_RREADY(pcie_axi_RREADY)
 );

sata_gth sata_gth_inst(
    .q6_clk1_gtrefclk_pad_p_in(q6_clk1_gtrefclk_pad_p_in), // GTH reference clock input
    .q6_clk1_gtrefclk_pad_n_in(q6_clk1_gtrefclk_pad_n_in), // GTH reference clock input
    .sysclk_in_p(sysclk_in_p), //100MHz differential system clock
    .sysclk_in_n(sysclk_in_n),
    .sata1_tx_p(sata1_tx_p),
    .sata1_tx_n(sata1_tx_n),
    .sata1_rx_p(sata1_rx_p),
    .sata1_rx_n(sata1_rx_n),
    
    .logic_clk(clk150),
    .gth_reset(gth_reset),
    .hard_reset(hard_reset),     // Active high, reset button pushed on board
    .soft_reset(soft_reset),     // Active high, user reset can be pulled any time
    //gth outputs
     // RX GTH tile <-> Link Module
    .RXELECIDLE0(RXELECIDLE0),
    .RXCHARISK0(RXCHARISK0),
    .RXDATA(RXDATA),
    .RXBYTEISALIGNED0(RXBYTEISALIGNED0),
    .gt0_rxbyterealign_out(gt0_rxbyterealign_out),
    .gt0_rxcommadet_out(gt0_rxcommadet_out),
    
     // TX GTH tile <-> Link Module
    .TXELECIDLE(TXELECIDLE),
    .TXDATA(TXDATA),
    .TXCHARISK(TXCHARISK),
          
    .rx_reset_done(rx_reset_done), 
    .tx_reset_done(tx_reset_done),
    .rx_comwake_det(rx_comwake_det),
    .rx_cominit_det(rx_cominit_det),
    .tx_cominit(tx_cominit), 
    .tx_comwake(tx_comwake),
    .rx_start(rx_start)
    );
    
mem_mcd_only_inf mem_inf_inst (
.clk156_25(axi_clk),
.reset156_25_n(aresetn),

//ddr3 pins
// Differential system clocks
.c0_sys_clk_p(c0_sys_clk_p),
.c0_sys_clk_n(c0_sys_clk_n),
.c1_sys_clk_p(c1_sys_clk_p),
.c1_sys_clk_n(c1_sys_clk_n),

// differential iodelayctrl clk (reference clock)
.clk_ref_p(clk_ref_p),
.clk_ref_n(clk_ref_n),
.sys_rst(pcie_reset & pok_dram),
//SODIMM 0
// Inouts
.c0_ddr3_dq(c0_ddr3_dq),
.c0_ddr3_dqs_n(c0_ddr3_dqs_n),
.c0_ddr3_dqs_p(c0_ddr3_dqs_p),

// Outputs
.c0_ddr3_addr(c0_ddr3_addr),
.c0_ddr3_ba(c0_ddr3_ba),
.c0_ddr3_ras_n(c0_ddr3_ras_n),
.c0_ddr3_cas_n(c0_ddr3_cas_n),
.c0_ddr3_we_n(c0_ddr3_we_n),
.c0_ddr3_reset_n(c0_ddr3_reset_n),
.c0_ddr3_ck_p(c0_ddr3_ck_p),
.c0_ddr3_ck_n(c0_ddr3_ck_n),
.c0_ddr3_cke(c0_ddr3_cke),
.c0_ddr3_cs_n(c0_ddr3_cs_n),
.c0_ddr3_odt(c0_ddr3_odt),
.c0_ui_clk(c0_ui_clk),
.c0_init_calib_complete(c0_init_calib_complete),

//SODIMM 1
// Inouts
.c1_ddr3_dq(c1_ddr3_dq),
.c1_ddr3_dqs_n(c1_ddr3_dqs_n),
.c1_ddr3_dqs_p(c1_ddr3_dqs_p),

// Outputs
.c1_ddr3_addr(c1_ddr3_addr),
.c1_ddr3_ba(c1_ddr3_ba),
.c1_ddr3_ras_n(c1_ddr3_ras_n),
.c1_ddr3_cas_n(c1_ddr3_cas_n),
.c1_ddr3_we_n(c1_ddr3_we_n),
.c1_ddr3_reset_n(c1_ddr3_reset_n),
.c1_ddr3_ck_p(c1_ddr3_ck_p),
.c1_ddr3_ck_n(c1_ddr3_ck_n),
.c1_ddr3_cke(c1_ddr3_cke),
.c1_ddr3_cs_n(c1_ddr3_cs_n),
.c1_ddr3_odt(c1_ddr3_odt),
//ui outputs
.c1_ui_clk(c1_ui_clk),
.c1_init_calib_complete(c1_init_calib_complete),

//ht stream interface signals
.ht_s_axis_read_cmd_tvalid(ht_s_axis_read_cmd_tvalid),
.ht_s_axis_read_cmd_tready(ht_s_axis_read_cmd_tready),
.ht_s_axis_read_cmd_tdata(ht_s_axis_read_cmd_tdata),
//read status
.ht_m_axis_read_sts_tvalid(ht_m_axis_read_sts_tvalid),
.ht_m_axis_read_sts_tready(ht_m_axis_read_sts_tready),
.ht_m_axis_read_sts_tdata(ht_m_axis_read_sts_tdata),
//read stream
.ht_m_axis_read_tdata(ht_m_axis_read_tdata),
.ht_m_axis_read_tkeep(ht_m_axis_read_tkeep),
.ht_m_axis_read_tlast(ht_m_axis_read_tlast),
.ht_m_axis_read_tvalid(ht_m_axis_read_tvalid),
.ht_m_axis_read_tready(ht_m_axis_read_tready),

//write commands
.ht_s_axis_write_cmd_tvalid(ht_s_axis_write_cmd_tvalid),
.ht_s_axis_write_cmd_tready(ht_s_axis_write_cmd_tready),
.ht_s_axis_write_cmd_tdata(ht_s_axis_write_cmd_tdata),
//write status
.ht_m_axis_write_sts_tvalid(ht_m_axis_write_sts_tvalid),
.ht_m_axis_write_sts_tready(ht_m_axis_write_sts_tready),
.ht_m_axis_write_sts_tdata(ht_m_axis_write_sts_tdata),
//write stream
.ht_s_axis_write_tdata(ht_s_axis_write_tdata),
.ht_s_axis_write_tkeep(ht_s_axis_write_tkeep),
.ht_s_axis_write_tlast(ht_s_axis_write_tlast),
.ht_s_axis_write_tvalid(ht_s_axis_write_tvalid),
.ht_s_axis_write_tready(ht_s_axis_write_tready),

//upd stream interface signals
.vs_s_axis_read_cmd_tvalid(vs_s_axis_read_cmd_tvalid),
.vs_s_axis_read_cmd_tready(vs_s_axis_read_cmd_tready),
.vs_s_axis_read_cmd_tdata(vs_s_axis_read_cmd_tdata),
//read status
.vs_m_axis_read_sts_tvalid(vs_m_axis_read_sts_tvalid),
.vs_m_axis_read_sts_tready(vs_m_axis_read_sts_tready),
.vs_m_axis_read_sts_tdata(vs_m_axis_read_sts_tdata),
//read stream
.vs_m_axis_read_tdata(vs_m_axis_read_tdata),
.vs_m_axis_read_tkeep(vs_m_axis_read_tkeep),
.vs_m_axis_read_tlast(vs_m_axis_read_tlast),
.vs_m_axis_read_tvalid(vs_m_axis_read_tvalid),
.vs_m_axis_read_tready(vs_m_axis_read_tready),

//write commands
.vs_s_axis_write_cmd_tvalid(vs_s_axis_write_cmd_tvalid),
.vs_s_axis_write_cmd_tready(vs_s_axis_write_cmd_tready),
.vs_s_axis_write_cmd_tdata(vs_s_axis_write_cmd_tdata),
//write status
.vs_m_axis_write_sts_tvalid(vs_m_axis_write_sts_tvalid),
.vs_m_axis_write_sts_tready(vs_m_axis_write_sts_tready),
.vs_m_axis_write_sts_tdata(vs_m_axis_write_sts_tdata),
//write stream
.vs_s_axis_write_tdata(vs_s_axis_write_tdata),
.vs_s_axis_write_tkeep(vs_s_axis_write_tkeep),
.vs_s_axis_write_tlast(vs_s_axis_write_tlast),
.vs_s_axis_write_tvalid(vs_s_axis_write_tvalid),
.vs_s_axis_write_tready(vs_s_axis_write_tready)
);    


//Output Converter
    ethoutconverter_top ethOutConverter_inst (
        .aclk(axi_clk),
        .aresetn(aresetn),
        .AXI4Stream_O_TVALID(AXI_M_Stream_TVALID),
        .AXI4Stream_O_TREADY(AXI_M_Stream_TREADY),
        .AXI4Stream_O_TDATA(AXI_M_Stream_TDATA),
        .AXI4Stream_O_TKEEP(AXI_M_Stream_TKEEP),
        .AXI4Stream_O_TLAST(AXI_M_Stream_TLAST),
        .inPacket_V_TVALID(axis_outStream_tvalid),
        .inPacket_V_TREADY(axis_outStream_tready),
        .inPacket_V_TDATA(axis_outStream_tdata)
);
//chipscope debugging -- mcdBbBinDummy_inExtractor.cpy
/*
reg [255:0] data;
reg [31:0] trig0;
reg [31:0] fcount_r;
wire [35:0] control0, control1;

chipscope_icon icon0
(
     .CONTROL0(control0),
     .CONTROL1(control1)
);

chipscope_ila ila0
(
     .CLK(axi_clk),
     .CONTROL(control0),
     .TRIG0(trig0),
     .DATA(data)
);

chipscope_vio vio0
(
     .CONTROL(control1),
     .ASYNC_OUT(vio_reset)
);

always @(posedge axi_clk) begin
    if (~aresetn)
        fcount_r <= 0;
    else if (axis_inStream_tdata[68]) begin
        fcount_r <= fcount_r + 1;
    end
end*/


endmodule
