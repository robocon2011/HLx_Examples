`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/11/2013 02:22:48 PM
// Design Name: 
// Module Name: mem_inf
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


module mem_mcd_only_inf
(
input clk156_25,
input reset156_25_n,

//ddr3 pins
// Differential system clocks
input				c0_sys_clk_p,
input				c0_sys_clk_n,
input				c1_sys_clk_p,
input				c1_sys_clk_n,

// differential iodelayctrl clk (reference clock)
input				clk_ref_p,
input				clk_ref_n,
input               sys_rst,
//SODIMM 0
// Inouts
inout [71:0]       c0_ddr3_dq,
inout [8:0]        c0_ddr3_dqs_n,
inout [8:0]        c0_ddr3_dqs_p,

// Outputs
output [15:0]     c0_ddr3_addr,
output [2:0]      c0_ddr3_ba,
output            c0_ddr3_ras_n,
output            c0_ddr3_cas_n,
output            c0_ddr3_we_n,
output            c0_ddr3_reset_n,
output[1:0]       c0_ddr3_ck_p,
output[1:0]       c0_ddr3_ck_n,
output[1:0]       c0_ddr3_cke,
output[1:0]       c0_ddr3_cs_n,
output[1:0]       c0_ddr3_odt,
output            c0_ui_clk,
output            c0_init_calib_complete,

//SODIMM 1
// Inouts
inout [71:0]      c1_ddr3_dq,
inout [8:0]       c1_ddr3_dqs_n,
inout [8:0]       c1_ddr3_dqs_p,

// Outputs
output [15:0]    c1_ddr3_addr,
output [2:0]     c1_ddr3_ba,
output           c1_ddr3_ras_n,
output           c1_ddr3_cas_n,
output           c1_ddr3_we_n,
output           c1_ddr3_reset_n,
output[1:0]      c1_ddr3_ck_p,
output[1:0]      c1_ddr3_ck_n,
output[1:0]      c1_ddr3_cke,
output[1:0]      c1_ddr3_cs_n,
output[1:0]      c1_ddr3_odt,
//ui outputs
output           c1_ui_clk,
output           c1_init_calib_complete,

//ht stream interface signals
input           ht_s_axis_read_cmd_tvalid,
output          ht_s_axis_read_cmd_tready,
input[71:0]     ht_s_axis_read_cmd_tdata,
//read status
output          ht_m_axis_read_sts_tvalid,
input           ht_m_axis_read_sts_tready,
output[7:0]     ht_m_axis_read_sts_tdata,
//read stream
output[511:0]    ht_m_axis_read_tdata,
output[63:0]     ht_m_axis_read_tkeep,
output          ht_m_axis_read_tlast,
output          ht_m_axis_read_tvalid,
input           ht_m_axis_read_tready,

//write commands
input           ht_s_axis_write_cmd_tvalid,
output          ht_s_axis_write_cmd_tready,
input[71:0]     ht_s_axis_write_cmd_tdata,
//write status
output          ht_m_axis_write_sts_tvalid,
input           ht_m_axis_write_sts_tready,
output[7:0]     ht_m_axis_write_sts_tdata,
//write stream
input[511:0]     ht_s_axis_write_tdata,
input[63:0]      ht_s_axis_write_tkeep,
input           ht_s_axis_write_tlast,
input           ht_s_axis_write_tvalid,
output          ht_s_axis_write_tready,

//upd stream interface signals
input           vs_s_axis_read_cmd_tvalid,
output          vs_s_axis_read_cmd_tready,
input[71:0]     vs_s_axis_read_cmd_tdata,
//read status
output          vs_m_axis_read_sts_tvalid,
input           vs_m_axis_read_sts_tready,
output[7:0]     vs_m_axis_read_sts_tdata,
//read stream
output[511:0]    vs_m_axis_read_tdata,
output[63:0]     vs_m_axis_read_tkeep,
output          vs_m_axis_read_tlast,
output          vs_m_axis_read_tvalid,
input           vs_m_axis_read_tready,

//write commands
input           vs_s_axis_write_cmd_tvalid,
output          vs_s_axis_write_cmd_tready,
input[71:0]     vs_s_axis_write_cmd_tdata,
//write status
output          vs_m_axis_write_sts_tvalid,
input           vs_m_axis_write_sts_tready,
output[7:0]     vs_m_axis_write_sts_tdata,
//write stream
input[511:0]     vs_s_axis_write_tdata,
input[63:0]      vs_s_axis_write_tkeep,
input            vs_s_axis_write_tlast,
input            vs_s_axis_write_tvalid,
output           vs_s_axis_write_tready
);

//TOE related ports. Currently unused for udp based mcd

//toe stream interface signals
wire    toeTX_s_axis_read_cmd_tvalid;
wire          toeTX_s_axis_read_cmd_tready;
wire[71:0]     toeTX_s_axis_read_cmd_tdata;
//read status
wire          toeTX_m_axis_read_sts_tvalid;
wire           toeTX_m_axis_read_sts_tready;
wire[7:0]     toeTX_m_axis_read_sts_tdata;
//read stream
wire[63:0]    toeTX_m_axis_read_tdata;
wire[7:0]     toeTX_m_axis_read_tkeep;
wire          toeTX_m_axis_read_tlast;
wire          toeTX_m_axis_read_tvalid;
wire           toeTX_m_axis_read_tready;

//write commands
wire           toeTX_s_axis_write_cmd_tvalid;
wire          toeTX_s_axis_write_cmd_tready;
wire[71:0]     toeTX_s_axis_write_cmd_tdata;
//write status
wire          toeTX_m_axis_write_sts_tvalid;
wire           toeTX_m_axis_write_sts_tready;
wire[31:0]     toeTX_m_axis_write_sts_tdata;
//write stream
wire[63:0]     toeTX_s_axis_write_tdata;
wire[7:0]      toeTX_s_axis_write_tkeep;
wire           toeTX_s_axis_write_tlast;
wire           toeTX_s_axis_write_tvalid;
wire          toeTX_s_axis_write_tready;

wire           toeRX_s_axis_read_cmd_tvalid;
wire          toeRX_s_axis_read_cmd_tready;
wire[71:0]     toeRX_s_axis_read_cmd_tdata;
//read status
wire          toeRX_m_axis_read_sts_tvalid;
wire           toeRX_m_axis_read_sts_tready;
wire[7:0]     toeRX_m_axis_read_sts_tdata;
//read stream
wire[63:0]    toeRX_m_axis_read_tdata;
wire[7:0]     toeRX_m_axis_read_tkeep;
wire          toeRX_m_axis_read_tlast;
wire          toeRX_m_axis_read_tvalid;
wire           toeRX_m_axis_read_tready;

//write commands
wire           toeRX_s_axis_write_cmd_tvalid;
wire          toeRX_s_axis_write_cmd_tready;
wire[71:0]     toeRX_s_axis_write_cmd_tdata;
//write status
wire          toeRX_m_axis_write_sts_tvalid;
wire           toeRX_m_axis_write_sts_tready;
wire[31:0]     toeRX_m_axis_write_sts_tdata;
//write stream
wire[63:0]     toeRX_s_axis_write_tdata;
wire[7:0]      toeRX_s_axis_write_tkeep;
wire           toeRX_s_axis_write_tlast;
wire           toeRX_s_axis_write_tvalid;
wire          toeRX_s_axis_write_tready;

 // user interface signals
wire                   c0_ui_clk_sync_rst;
wire                   c0_mmcm_locked;
      
reg                    c0_aresetn_r;
   
// Slave Interface Write Address Ports
wire  [4:0]            c0_s_axi_awid;
wire  [32:0]           c0_s_axi_awaddr;
wire  [7:0]            c0_s_axi_awlen;
wire  [2:0]            c0_s_axi_awsize;
wire  [1:0]            c0_s_axi_awburst;

wire                   c0_s_axi_awvalid;
wire                   c0_s_axi_awready;
// Slave Interface Write Data Ports
wire  [511:0]          c0_s_axi_wdata;
wire  [63:0]           c0_s_axi_wstrb;
wire                   c0_s_axi_wlast;
wire                   c0_s_axi_wvalid;
wire                   c0_s_axi_wready;
// Slave Interface Write Response Ports
wire                   c0_s_axi_bready;
wire [4:0]             c0_s_axi_bid;
wire [1:0]             c0_s_axi_bresp;
wire                   c0_s_axi_bvalid;
// Slave Interface Read Address Ports
wire  [4:0]           c0_s_axi_arid;
wire  [32:0]          c0_s_axi_araddr;
wire  [7:0]           c0_s_axi_arlen;
wire  [2:0]           c0_s_axi_arsize;
wire  [1:0]           c0_s_axi_arburst;
wire                  c0_s_axi_arvalid;
wire                  c0_s_axi_arready;
// Slave Interface Read Data Ports
wire             c0_s_axi_rready;
wire [4:0]       c0_s_axi_rid;
wire [511:0]     c0_s_axi_rdata;
wire [1:0]       c0_s_axi_rresp;
wire             c0_s_axi_rlast;
wire             c0_s_axi_rvalid;

// user interface signals
wire             c1_ui_clk_sync_rst;
wire             c1_mmcm_locked;
      
reg              c1_aresetn_r;
   
// Slave Interface Write Address Ports
wire [4:0]      c1_s_axi_awid;
wire [32:0]     c1_s_axi_awaddr;
wire [7:0]      c1_s_axi_awlen;
wire [2:0]      c1_s_axi_awsize;
wire [1:0]      c1_s_axi_awburst;

wire            c1_s_axi_awvalid;
wire            c1_s_axi_awready;
// Slave Interface Write Data Ports
wire [511:0]    c1_s_axi_wdata;
wire [63:0]     c1_s_axi_wstrb;
wire            c1_s_axi_wlast;
wire            c1_s_axi_wvalid;
wire            c1_s_axi_wready;
// Slave Interface Write Response Ports
wire            c1_s_axi_bready;
wire [4:0]      c1_s_axi_bid;
wire [1:0]      c1_s_axi_bresp;
wire            c1_s_axi_bvalid;
// Slave Interface Read Address Ports
wire [4:0]      c1_s_axi_arid;
wire [32:0]     c1_s_axi_araddr;
wire [7:0]      c1_s_axi_arlen;
wire [2:0]      c1_s_axi_arsize;
wire [1:0]      c1_s_axi_arburst;
wire            c1_s_axi_arvalid;
wire            c1_s_axi_arready;
// Slave Interface Read Data Ports
wire            c1_s_axi_rready;
wire [4:0]      c1_s_axi_rid;
wire [511:0]    c1_s_axi_rdata;
wire [1:0]      c1_s_axi_rresp;
wire            c1_s_axi_rlast;
wire            c1_s_axi_rvalid;

//tie out TOE related signals.
//toe stream interface signals
assign     toeTX_s_axis_read_cmd_tvalid = 1'b0;
assign     toeTX_s_axis_read_cmd_tdata = 72'b0;
//read status
assign     toeTX_m_axis_read_sts_tready = 1'b1;
//read stream
assign           toeTX_m_axis_read_tready = 1'b1;

//write commands
assign   toeTX_s_axis_write_cmd_tvalid = 1'b0;
assign   toeTX_s_axis_write_cmd_tdata = 72'b0;
//write status
assign   toeTX_m_axis_write_sts_tready = 1'b1;

//write stream
assign     toeTX_s_axis_write_tdata = 64'b0;
assign     toeTX_s_axis_write_tkeep = 8'b0;
assign     toeTX_s_axis_write_tlast = 1'b0;
assign     toeTX_s_axis_write_tvalid = 1'b0;

assign    toeRX_s_axis_read_cmd_tvalid = 1'b0;
assign    toeRX_s_axis_read_cmd_tdata = 72'b0;
//read status
assign     toeRX_m_axis_read_sts_tready = 1'b1;

//read stream
assign     toeRX_m_axis_read_tready = 1'b1;

//write commands
assign     toeRX_s_axis_write_cmd_tvalid = 1'b0;
assign     toeRX_s_axis_write_cmd_tdata = 72'b0;
//write status
assign     toeRX_m_axis_write_sts_tready = 1'b1;

//write stream
assign     toeRX_s_axis_write_tdata = 64'b0;
assign     toeRX_s_axis_write_tkeep = 8'b0;
assign     toeRX_s_axis_write_tlast = 1'b0;
assign     toeRX_s_axis_write_tvalid = 1'b0;

//currently only use 32 bit address because vivado 2013.4 does not support 33 bit address, need vivado 2014.2
assign c0_s_axi_awaddr[32] = 1'b0;
assign c0_s_axi_araddr[32] = 1'b0;
assign c1_s_axi_awaddr[32] = 1'b0;
assign c1_s_axi_araddr[32] = 1'b0;

assign c0_s_axi_awid[4] = 1'b0;
assign c0_s_axi_arid[4] = 1'b0;
assign c0_s_axi_rid[4] = 1'b0;
assign c1_s_axi_awid[4] = 1'b0;
assign c1_s_axi_arid[4] = 1'b0;
assign c1_s_axi_rid[4] = 1'b0;

always @(posedge c0_ui_clk)
    c0_aresetn_r <= ~c0_ui_clk_sync_rst & c0_mmcm_locked;
    
always @(posedge c1_ui_clk)
    c1_aresetn_r <= ~c1_ui_clk_sync_rst & c1_mmcm_locked;

//mig_axi_mm_dual u_mig_axi_mm_dual_inst (
mig_7series_0 u_mig_axi_mm_dual_inst (
    // Memory interface ports
       .c0_ddr3_addr                      (c0_ddr3_addr),
       .c0_ddr3_ba                        (c0_ddr3_ba),
       .c0_ddr3_cas_n                     (c0_ddr3_cas_n),
       .c0_ddr3_ck_n                      (c0_ddr3_ck_n),
       .c0_ddr3_ck_p                      (c0_ddr3_ck_p),
       .c0_ddr3_cke                       (c0_ddr3_cke),
       .c0_ddr3_ras_n                     (c0_ddr3_ras_n),
       .c0_ddr3_reset_n                   (c0_ddr3_reset_n),
       .c0_ddr3_we_n                      (c0_ddr3_we_n),
       .c0_ddr3_dq                        (c0_ddr3_dq),
       .c0_ddr3_dqs_n                     (c0_ddr3_dqs_n),
       .c0_ddr3_dqs_p                     (c0_ddr3_dqs_p),
       .c0_init_calib_complete            (c0_init_calib_complete),
      
       .c0_ddr3_cs_n                      (c0_ddr3_cs_n),
       .c0_ddr3_odt                       (c0_ddr3_odt),
// Application interface ports
       .c0_ui_clk                         (c0_ui_clk),
       .c0_ui_clk_sync_rst                (c0_ui_clk_sync_rst),

       .c0_mmcm_locked                    (c0_mmcm_locked),
       .c0_aresetn                        (c0_aresetn_r),
       .c0_app_sr_req                     (1'b0),
       .c0_app_ref_req                    (1'b0),
       .c0_app_zq_req                     (1'b0),
       .c0_app_sr_active                  (),
       .c0_app_ref_ack                    (),
       .c0_app_zq_ack                     (),

// Slave Interface Write Address Ports
       .c0_s_axi_awid                     (c0_s_axi_awid),
       .c0_s_axi_awaddr                   (c0_s_axi_awaddr),
       .c0_s_axi_awlen                    (c0_s_axi_awlen),
       .c0_s_axi_awsize                   (c0_s_axi_awsize),
       .c0_s_axi_awburst                  (c0_s_axi_awburst),
       .c0_s_axi_awlock                   (2'b0),
       .c0_s_axi_awcache                  (4'b0),
       .c0_s_axi_awprot                   (3'b0),
       .c0_s_axi_awqos                    (4'h0),
       .c0_s_axi_awvalid                  (c0_s_axi_awvalid),
       .c0_s_axi_awready                  (c0_s_axi_awready),
// Slave Interface Write Data Ports
       .c0_s_axi_wdata                    (c0_s_axi_wdata),
       .c0_s_axi_wstrb                    (c0_s_axi_wstrb),
       .c0_s_axi_wlast                    (c0_s_axi_wlast),
       .c0_s_axi_wvalid                   (c0_s_axi_wvalid),
       .c0_s_axi_wready                   (c0_s_axi_wready),
// Slave Interface Write Response Ports
       .c0_s_axi_bid                      (c0_s_axi_bid),
       .c0_s_axi_bresp                    (c0_s_axi_bresp),
       .c0_s_axi_bvalid                   (c0_s_axi_bvalid),
       .c0_s_axi_bready                   (c0_s_axi_bready),
// Slave Interface Read Address Ports
       .c0_s_axi_arid                     (c0_s_axi_arid),
       .c0_s_axi_araddr                   (c0_s_axi_araddr),
       .c0_s_axi_arlen                    (c0_s_axi_arlen),
       .c0_s_axi_arsize                   (c0_s_axi_arsize),
       .c0_s_axi_arburst                  (c0_s_axi_arburst),
       .c0_s_axi_arlock                   (2'b0),
       .c0_s_axi_arcache                  (4'b0),
       .c0_s_axi_arprot                   (3'b0),
       .c0_s_axi_arqos                    (4'h0),
       .c0_s_axi_arvalid                  (c0_s_axi_arvalid),
       .c0_s_axi_arready                  (c0_s_axi_arready),
// Slave Interface Read Data Ports
       .c0_s_axi_rid                      (c0_s_axi_rid),
       .c0_s_axi_rdata                    (c0_s_axi_rdata),
       .c0_s_axi_rresp                    (c0_s_axi_rresp),
       .c0_s_axi_rlast                    (c0_s_axi_rlast),
       .c0_s_axi_rvalid                   (c0_s_axi_rvalid),
       .c0_s_axi_rready                   (c0_s_axi_rready),
// AXI CTRL port
       .c0_s_axi_ctrl_awvalid             (1'b0),
       .c0_s_axi_ctrl_awready             (),
       .c0_s_axi_ctrl_awaddr              ('b0),
// Slave Interface Write Data Ports
       .c0_s_axi_ctrl_wvalid              (1'b0),
       .c0_s_axi_ctrl_wready              (),
       .c0_s_axi_ctrl_wdata               ('b0),
// Slave Interface Write Response Ports
       .c0_s_axi_ctrl_bvalid              (),
       .c0_s_axi_ctrl_bready              (1'b1),
       .c0_s_axi_ctrl_bresp               (),
// Slave Interface Read Address Ports
       .c0_s_axi_ctrl_arvalid             (1'b0),
       .c0_s_axi_ctrl_arready             (),
       .c0_s_axi_ctrl_araddr              ('b0),
// Slave Interface Read Data Ports
       .c0_s_axi_ctrl_rvalid              (),
       .c0_s_axi_ctrl_rready              (1'b1),
       .c0_s_axi_ctrl_rdata               (),
       .c0_s_axi_ctrl_rresp               (),
// Interrupt output
       .c0_interrupt                      (),
      .c0_app_ecc_multiple_err           (),
       
// System Clock Ports
       .c0_sys_clk_p                       (c0_sys_clk_p),
       .c0_sys_clk_n                       (c0_sys_clk_n),
// Reference Clock Ports
       .clk_ref_p                      (clk_ref_p),
       .clk_ref_n                      (clk_ref_n),
      
       
// Memory interface ports
       .c1_ddr3_addr                      (c1_ddr3_addr),
       .c1_ddr3_ba                        (c1_ddr3_ba),
       .c1_ddr3_cas_n                     (c1_ddr3_cas_n),
       .c1_ddr3_ck_n                      (c1_ddr3_ck_n),
       .c1_ddr3_ck_p                      (c1_ddr3_ck_p),
       .c1_ddr3_cke                       (c1_ddr3_cke),
       .c1_ddr3_ras_n                     (c1_ddr3_ras_n),
       .c1_ddr3_reset_n                   (c1_ddr3_reset_n),
       .c1_ddr3_we_n                      (c1_ddr3_we_n),
       .c1_ddr3_dq                        (c1_ddr3_dq),
       .c1_ddr3_dqs_n                     (c1_ddr3_dqs_n),
       .c1_ddr3_dqs_p                     (c1_ddr3_dqs_p),
       .c1_init_calib_complete            (c1_init_calib_complete),
      
       .c1_ddr3_cs_n                      (c1_ddr3_cs_n),
       .c1_ddr3_odt                       (c1_ddr3_odt),
// Application interface ports
       .c1_ui_clk                         (c1_ui_clk),
       .c1_ui_clk_sync_rst                (c1_ui_clk_sync_rst),

       .c1_mmcm_locked                    (c1_mmcm_locked),
       .c1_aresetn                        (c1_aresetn_r),
       .c1_app_sr_req                     (1'b0),
       .c1_app_ref_req                    (1'b0),
       .c1_app_zq_req                     (1'b0),
       .c1_app_sr_active                  (),
       .c1_app_ref_ack                    (),
       .c1_app_zq_ack                     (),

// Slave Interface Write Address Ports
       .c1_s_axi_awid                     (c1_s_axi_awid),
       .c1_s_axi_awaddr                   (c1_s_axi_awaddr),
       .c1_s_axi_awlen                    (c1_s_axi_awlen),
       .c1_s_axi_awsize                   (c1_s_axi_awsize),
       .c1_s_axi_awburst                  (c1_s_axi_awburst),
       .c1_s_axi_awlock                   (2'b0),
       .c1_s_axi_awcache                  (4'b0),
       .c1_s_axi_awprot                   (3'b0),
       .c1_s_axi_awqos                    (4'h0),
       .c1_s_axi_awvalid                  (c1_s_axi_awvalid),
       .c1_s_axi_awready                  (c1_s_axi_awready),
// Slave Interface Write Data Ports
       .c1_s_axi_wdata                    (c1_s_axi_wdata),
       .c1_s_axi_wstrb                    (c1_s_axi_wstrb),
       .c1_s_axi_wlast                    (c1_s_axi_wlast),
       .c1_s_axi_wvalid                   (c1_s_axi_wvalid),
       .c1_s_axi_wready                   (c1_s_axi_wready),
// Slave Interface Write Response Ports
       .c1_s_axi_bid                      (c1_s_axi_bid),
       .c1_s_axi_bresp                    (c1_s_axi_bresp),
       .c1_s_axi_bvalid                   (c1_s_axi_bvalid),
       .c1_s_axi_bready                   (c1_s_axi_bready),
// Slave Interface Read Address Ports
       .c1_s_axi_arid                     (c1_s_axi_arid),
       .c1_s_axi_araddr                   (c1_s_axi_araddr),
       .c1_s_axi_arlen                    (c1_s_axi_arlen),
       .c1_s_axi_arsize                   (c1_s_axi_arsize),
       .c1_s_axi_arburst                  (c1_s_axi_arburst),
       .c1_s_axi_arlock                   (2'b0),
       .c1_s_axi_arcache                  (4'b0),
       .c1_s_axi_arprot                   (3'b0),
       .c1_s_axi_arqos                    (4'h0),
       .c1_s_axi_arvalid                  (c1_s_axi_arvalid),
       .c1_s_axi_arready                  (c1_s_axi_arready),
// Slave Interface Read Data Ports
       .c1_s_axi_rid                      (c1_s_axi_rid),
       .c1_s_axi_rdata                    (c1_s_axi_rdata),
       .c1_s_axi_rresp                    (c1_s_axi_rresp),
       .c1_s_axi_rlast                    (c1_s_axi_rlast),
       .c1_s_axi_rvalid                   (c1_s_axi_rvalid),
       .c1_s_axi_rready                   (c1_s_axi_rready),
// AXI CTRL port
       .c1_s_axi_ctrl_awvalid             (1'b0),
       .c1_s_axi_ctrl_awready             (),
       .c1_s_axi_ctrl_awaddr              ('b0),
// Slave Interface Write Data Ports
       .c1_s_axi_ctrl_wvalid              (1'b0),
       .c1_s_axi_ctrl_wready              (),
       .c1_s_axi_ctrl_wdata               ('b0),
// Slave Interface Write Response Ports
       .c1_s_axi_ctrl_bvalid              (),
       .c1_s_axi_ctrl_bready              (1'b1),
       .c1_s_axi_ctrl_bresp               (),
// Slave Interface Read Address Ports
       .c1_s_axi_ctrl_arvalid             (1'b0),
       .c1_s_axi_ctrl_arready             (),
       .c1_s_axi_ctrl_araddr              ('b0),
// Slave Interface Read Data Ports
       .c1_s_axi_ctrl_rvalid              (),
       .c1_s_axi_ctrl_rready              (1'b1),
       .c1_s_axi_ctrl_rdata               (),
       .c1_s_axi_ctrl_rresp               (),
// Interrupt output
       .c1_interrupt                      (),
      .c1_app_ecc_multiple_err           (),
       
// System Clock Ports
       .c1_sys_clk_p                       (c1_sys_clk_p),
       .c1_sys_clk_n                       (c1_sys_clk_n),
      
       .sys_rst                        (sys_rst) //system reset active high   
    );

//instantiate mcd_mem_inf
mcd_mem_inf mcd_mem_inf_inst(
    .S_AXI_ACLK(clk156_25),
    .S_ARESETN(reset156_25_n),
    
    //axi streams from hash table and update module (also called vs module)
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
    .vs_s_axis_write_tready(vs_s_axis_write_tready),
    
    // master axi Interface -- should be connected to the axi4 ports of mig
    .M00_AXI_ACLK(c1_ui_clk),
    .M00_AXI_AWID(c1_s_axi_awid[3:0]),
    .M00_AXI_AWADDR(c1_s_axi_awaddr[31:0]),
    .M00_AXI_AWLEN(c1_s_axi_awlen),
    .M00_AXI_AWSIZE(c1_s_axi_awsize),
    .M00_AXI_AWBURST(c1_s_axi_awburst),
    
    .M00_AXI_AWVALID(c1_s_axi_awvalid),
    .M00_AXI_AWREADY(c1_s_axi_awready),
    .M00_AXI_WDATA(c1_s_axi_wdata),
    .M00_AXI_WSTRB(c1_s_axi_wstrb),
    .M00_AXI_WLAST(c1_s_axi_wlast),
    .M00_AXI_WVALID(c1_s_axi_wvalid),
    .M00_AXI_WREADY(c1_s_axi_wready),
    .M00_AXI_BID(c1_s_axi_bid[3:0]),
    .M00_AXI_BRESP(c1_s_axi_bresp),
    .M00_AXI_BVALID(c1_s_axi_bvalid),
    .M00_AXI_BREADY(c1_s_axi_bready),
    .M00_AXI_ARID(c1_s_axi_arid[3:0]),
    .M00_AXI_ARADDR(c1_s_axi_araddr[31:0]),
    .M00_AXI_ARLEN(c1_s_axi_arlen),
    .M00_AXI_ARSIZE(c1_s_axi_arsize),
    .M00_AXI_ARBURST(c1_s_axi_arburst),
    .M00_AXI_ARVALID(c1_s_axi_arvalid),
    .M00_AXI_ARREADY(c1_s_axi_arready),
    .M00_AXI_RID(c1_s_axi_rid[3:0]),
    .M00_AXI_RDATA(c1_s_axi_rdata),
    .M00_AXI_RRESP(c1_s_axi_rresp),
    .M00_AXI_RLAST(c1_s_axi_rlast),
    .M00_AXI_RVALID(c1_s_axi_rvalid),
    .M00_AXI_RREADY(c1_s_axi_rready)
    );
    
//instantiate toe mem interface
toe_mem_inf toe_mem_inf_inst(
    .S_AXI_ACLK(clk156_25),
    .S_ARESETN(reset156_25_n),
    
        //toe stream interface signals
    .toeTX_s_axis_read_cmd_tvalid(toeTX_s_axis_read_cmd_tvalid),
    .toeTX_s_axis_read_cmd_tready(toeTX_s_axis_read_cmd_tready),
    .toeTX_s_axis_read_cmd_tdata(toeTX_s_axis_read_cmd_tdata),
    //read status
    .toeTX_m_axis_read_sts_tvalid(toeTX_m_axis_read_sts_tvalid),
    .toeTX_m_axis_read_sts_tready(toeTX_m_axis_read_sts_tready),
    .toeTX_m_axis_read_sts_tdata(toeTX_m_axis_read_sts_tdata),
    //read stream
    .toeTX_m_axis_read_tdata(toeTX_m_axis_read_tdata),
    .toeTX_m_axis_read_tkeep(toeTX_m_axis_read_tkeep),
    .toeTX_m_axis_read_tlast(toeTX_m_axis_read_tlast),
    .toeTX_m_axis_read_tvalid(toeTX_m_axis_read_tvalid),
    .toeTX_m_axis_read_tready(toeTX_m_axis_read_tready),
    
    //write commands
    .toeTX_s_axis_write_cmd_tvalid(toeTX_s_axis_write_cmd_tvalid),
    .toeTX_s_axis_write_cmd_tready(toeTX_s_axis_write_cmd_tready),
    .toeTX_s_axis_write_cmd_tdata(toeTX_s_axis_write_cmd_tdata),
    //write status
    .toeTX_m_axis_write_sts_tvalid(toeTX_m_axis_write_sts_tvalid),
    .toeTX_m_axis_write_sts_tready(toeTX_m_axis_write_sts_tready),
    .toeTX_m_axis_write_sts_tdata(toeTX_m_axis_write_sts_tdata),
    //write stream
    .toeTX_s_axis_write_tdata(toeTX_s_axis_write_tdata),
    .toeTX_s_axis_write_tkeep(toeTX_s_axis_write_tkeep),
    .toeTX_s_axis_write_tlast(toeTX_s_axis_write_tlast),
    .toeTX_s_axis_write_tvalid(toeTX_s_axis_write_tvalid),
    .toeTX_s_axis_write_tready(toeTX_s_axis_write_tready),
    
    .toeRX_s_axis_read_cmd_tvalid(toeRX_s_axis_read_cmd_tvalid),
    .toeRX_s_axis_read_cmd_tready(toeRX_s_axis_read_cmd_tready),
    .toeRX_s_axis_read_cmd_tdata(toeRX_s_axis_read_cmd_tdata),
    //read status
    .toeRX_m_axis_read_sts_tvalid(toeRX_m_axis_read_sts_tvalid),
    .toeRX_m_axis_read_sts_tready(toeRX_m_axis_read_sts_tready),
    .toeRX_m_axis_read_sts_tdata(toeRX_m_axis_read_sts_tdata),
    //read stream
    .toeRX_m_axis_read_tdata(toeRX_m_axis_read_tdata),
    .toeRX_m_axis_read_tkeep(toeRX_m_axis_read_tkeep),
    .toeRX_m_axis_read_tlast(toeRX_m_axis_read_tlast),
    .toeRX_m_axis_read_tvalid(toeRX_m_axis_read_tvalid),
    .toeRX_m_axis_read_tready(toeRX_m_axis_read_tready),
    
    //write commands
    .toeRX_s_axis_write_cmd_tvalid(toeRX_s_axis_write_cmd_tvalid),
    .toeRX_s_axis_write_cmd_tready(toeRX_s_axis_write_cmd_tready),
    .toeRX_s_axis_write_cmd_tdata(toeRX_s_axis_write_cmd_tdata),
    //write status
    .toeRX_m_axis_write_sts_tvalid(toeRX_m_axis_write_sts_tvalid),
    .toeRX_m_axis_write_sts_tready(toeRX_m_axis_write_sts_tready),
    .toeRX_m_axis_write_sts_tdata(toeRX_m_axis_write_sts_tdata),
    //write stream
    .toeRX_s_axis_write_tdata(toeRX_s_axis_write_tdata),
    .toeRX_s_axis_write_tkeep(toeRX_s_axis_write_tkeep),
    .toeRX_s_axis_write_tlast(toeRX_s_axis_write_tlast),
    .toeRX_s_axis_write_tvalid(toeRX_s_axis_write_tvalid),
    .toeRX_s_axis_write_tready(toeRX_s_axis_write_tready),
    
    // master axi Interface -- should be connected to the axi4 ports of mig
    .M00_AXI_ACLK(c0_ui_clk),
    .M00_AXI_AWID(c0_s_axi_awid[3:0]),
    .M00_AXI_AWADDR(c0_s_axi_awaddr[31:0]),
    .M00_AXI_AWLEN(c0_s_axi_awlen),
    .M00_AXI_AWSIZE(c0_s_axi_awsize),
    .M00_AXI_AWBURST(c0_s_axi_awburst),
    
    .M00_AXI_AWVALID(c0_s_axi_awvalid),
    .M00_AXI_AWREADY(c0_s_axi_awready),
    .M00_AXI_WDATA(c0_s_axi_wdata),
    .M00_AXI_WSTRB(c0_s_axi_wstrb),
    .M00_AXI_WLAST(c0_s_axi_wlast),
    .M00_AXI_WVALID(c0_s_axi_wvalid),
    .M00_AXI_WREADY(c0_s_axi_wready),
    .M00_AXI_BID(c0_s_axi_bid[3:0]),
    .M00_AXI_BRESP(c0_s_axi_bresp),
    .M00_AXI_BVALID(c0_s_axi_bvalid),
    .M00_AXI_BREADY(c0_s_axi_bready),
    .M00_AXI_ARID(c0_s_axi_arid[3:0]),
    .M00_AXI_ARADDR(c0_s_axi_araddr[31:0]),
    .M00_AXI_ARLEN(c0_s_axi_arlen),
    .M00_AXI_ARSIZE(c0_s_axi_arsize),
    .M00_AXI_ARBURST(c0_s_axi_arburst),
    .M00_AXI_ARVALID(c0_s_axi_arvalid),
    .M00_AXI_ARREADY(c0_s_axi_arready),
    .M00_AXI_RID(c0_s_axi_rid[3:0]),
    .M00_AXI_RDATA(c0_s_axi_rdata),
    .M00_AXI_RRESP(c0_s_axi_rresp),
    .M00_AXI_RLAST(c0_s_axi_rlast),
    .M00_AXI_RVALID(c0_s_axi_rvalid),
    .M00_AXI_RREADY(c0_s_axi_rready)
 );
 
 //chipscope debugging
 /*reg [255:0] data;
 reg [31:0]  trig0;
 wire [35:0] control0, control1;
 wire vio_reset; //active high
 
 chipscope_icon icon0
 (
     .CONTROL0 (control0),
     .CONTROL1 (control1)
 );
 
 chipscope_ila ila0
 (
     .CLK     (c1_ui_clk),
     .CONTROL (control0),
     .TRIG0   (trig0),
     .DATA    (data)
 );
 chipscope_vio vio0
 (
     .CONTROL(control1),
     .ASYNC_OUT(vio_reset)
 );
 
 always @(posedge c1_ui_clk) begin
     data[0] <= c1_s_axi_awvalid;
     data[1] <= c1_s_axi_awready;
     data[2] <= c1_s_axi_wvalid;
     data[3] <= c1_s_axi_wready;
     data[7:4] <= c1_s_axi_arid[3:0];
     data[39:8] <= c1_s_axi_araddr[31:0];
     data[47:40] <= c1_s_axi_arlen;
     data[50:48] <= c1_s_axi_arsize;
     data[52:51] <= c1_s_axi_arburst;
     data[53] <= c1_s_axi_arvalid;
     data[54] <= c1_s_axi_arready;
     data[55] <= c1_s_axi_rready;
     data[60:56] <= c1_s_axi_rid;
     data[62:61] <= c1_s_axi_rresp;
     data[63] <= c1_s_axi_rlast;
     data[64] <= c1_s_axi_rvalid;
     
    trig0[0] <= c1_s_axi_arvalid;
    trig0[1] <= c1_s_axi_arready;
    trig0[2] <= c1_s_axi_rready;
    trig0[3] <= c1_s_axi_rlast;
    trig0[4] <= c1_s_axi_rvalid;
 end*/
endmodule
