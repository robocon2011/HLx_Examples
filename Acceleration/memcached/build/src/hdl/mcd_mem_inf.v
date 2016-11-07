`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 07/03/2014 12:01:56 PM
// Design Name: 
// Module Name: mcd_mem_inf
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


module mcd_mem_inf(
    input S_AXI_ACLK,
    input S_ARESETN,
    
    //axi streams from hash table and update module (also called vs module)
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
    output           vs_s_axis_write_tready,
    
    // master axi Interface -- should be connected to the axi4 ports of mig
    input M00_AXI_ACLK,
    output [3 : 0] M00_AXI_AWID,
    output [31 : 0] M00_AXI_AWADDR,
    output [7 : 0] M00_AXI_AWLEN,
    output [2 : 0] M00_AXI_AWSIZE,
    output [1 : 0] M00_AXI_AWBURST,
    
    output M00_AXI_AWVALID,
    input M00_AXI_AWREADY,
    output [511 : 0] M00_AXI_WDATA,
    output [63 : 0] M00_AXI_WSTRB,
    output M00_AXI_WLAST,
    output M00_AXI_WVALID,
    input M00_AXI_WREADY,
    input [3 : 0] M00_AXI_BID,
    input [1 : 0] M00_AXI_BRESP,
    input M00_AXI_BVALID,
    output M00_AXI_BREADY,
    output [3 : 0] M00_AXI_ARID,
    output [31 : 0] M00_AXI_ARADDR,
    output [7 : 0] M00_AXI_ARLEN,
    output [2 : 0] M00_AXI_ARSIZE,
    output [1 : 0] M00_AXI_ARBURST,
    output M00_AXI_ARVALID,
    input M00_AXI_ARREADY,
    input [3 : 0] M00_AXI_RID,
    input [511 : 0] M00_AXI_RDATA,
    input [1 : 0] M00_AXI_RRESP,
    input M00_AXI_RLAST,
    input M00_AXI_RVALID,
    output M00_AXI_RREADY
    );
    
    wire [0 : 0] S00_AXI_AWID;
    wire [31 : 0] S00_AXI_AWADDR;
    wire [7 : 0] S00_AXI_AWLEN;
    wire [2 : 0] S00_AXI_AWSIZE;
    wire [1 : 0] S00_AXI_AWBURST;
   
    wire S00_AXI_AWVALID;
    wire S00_AXI_AWREADY;
    wire [511 : 0] S00_AXI_WDATA;
    wire [63 : 0] S00_AXI_WSTRB;
    wire S00_AXI_WLAST;
    wire S00_AXI_WVALID;
    wire S00_AXI_WREADY;
    wire [0 : 0] S00_AXI_BID;
    wire [1 : 0] S00_AXI_BRESP;
    wire S00_AXI_BVALID;
    wire S00_AXI_BREADY;
    wire [0 : 0] S00_AXI_ARID;
    wire [31 : 0] S00_AXI_ARADDR;
    wire [7 : 0] S00_AXI_ARLEN;
    wire [2 : 0] S00_AXI_ARSIZE;
    wire [1 : 0] S00_AXI_ARBURST;
    wire S00_AXI_ARVALID;
    wire S00_AXI_ARREADY;
    wire [0 : 0] S00_AXI_RID;
    wire [511 : 0] S00_AXI_RDATA;
    wire [1 : 0] S00_AXI_RRESP;
    wire S00_AXI_RLAST;
    wire S00_AXI_RVALID;
    wire S00_AXI_RREADY;
    
    wire [0 : 0] S01_AXI_AWID;
    wire [31 : 0] S01_AXI_AWADDR;
    wire [7 : 0] S01_AXI_AWLEN;
    wire [2 : 0] S01_AXI_AWSIZE;
    wire [1 : 0] S01_AXI_AWBURST;
    wire S01_AXI_AWLOCK;
    wire [3 : 0] S01_AXI_AWCACHE;
    wire [2 : 0] S01_AXI_AWPROT;
    wire [3 : 0] S01_AXI_AWQOS;
    wire S01_AXI_AWVALID;
    wire S01_AXI_AWREADY;
    wire [511 : 0] S01_AXI_WDATA;
    wire [63 : 0] S01_AXI_WSTRB;
    wire S01_AXI_WLAST;
    wire S01_AXI_WVALID;
    wire S01_AXI_WREADY;
    wire [0 : 0] S01_AXI_BID;
    wire [1 : 0] S01_AXI_BRESP;
    wire S01_AXI_BVALID;
    wire S01_AXI_BREADY;
    wire [0 : 0] S01_AXI_ARID;
    wire [31 : 0] S01_AXI_ARADDR;
    wire [7 : 0] S01_AXI_ARLEN;
    wire [2 : 0] S01_AXI_ARSIZE;
    wire [1 : 0] S01_AXI_ARBURST;
    wire S01_AXI_ARLOCK;
    wire [3 : 0] S01_AXI_ARCACHE;
    wire [2 : 0] S01_AXI_ARPROT;
    wire [3 : 0] S01_AXI_ARQOS;
    wire S01_AXI_ARVALID;
    wire S01_AXI_ARREADY;
    wire [0 : 0] S01_AXI_RID;
    wire [511 : 0] S01_AXI_RDATA;
    wire [1 : 0] S01_AXI_RRESP;
    wire S01_AXI_RLAST;
    wire S01_AXI_RVALID;
    wire S01_AXI_RREADY;
    
    wire [3:0] S00_AXI_ARID_x, S00_AXI_AWID_x;
    wire [3:0] S01_AXI_ARID_x, S01_AXI_AWID_x;
    
    assign S00_AXI_ARID = S00_AXI_ARID_x[0];
    assign S00_AXI_AWID = S00_AXI_AWID_x[0];
    assign S01_AXI_ARID = S01_AXI_ARID_x[0];
    assign S01_AXI_AWID = S01_AXI_AWID_x[0];
    
 //axi interconnect connecting two data movers to one dimm channel
  axi_interconnect_2s axi_interconnect_inst (
   .INTERCONNECT_ACLK(S_AXI_ACLK),        // input wire INTERCONNECT_ACLK
   .INTERCONNECT_ARESETN(S_ARESETN),  // input wire INTERCONNECT_ARESETN
   .S00_AXI_ARESET_OUT_N(),  // output wire S00_AXI_ARESET_OUT_N
   .S00_AXI_ACLK(S_AXI_ACLK),                  // input wire S00_AXI_ACLK
   .S00_AXI_AWID(S00_AXI_AWID),                  // input wire [0 : 0] S00_AXI_AWID
   .S00_AXI_AWADDR(S00_AXI_AWADDR),              // input wire [31 : 0] S00_AXI_AWADDR
   .S00_AXI_AWLEN(S00_AXI_AWLEN),                // input wire [7 : 0] S00_AXI_AWLEN
   .S00_AXI_AWSIZE(S00_AXI_AWSIZE),              // input wire [2 : 0] S00_AXI_AWSIZE
   .S00_AXI_AWBURST(S00_AXI_AWBURST),            // input wire [1 : 0] S00_AXI_AWBURST
   .S00_AXI_AWLOCK(1'b0),              // input wire S00_AXI_AWLOCK
   .S00_AXI_AWCACHE(4'b0),            // input wire [3 : 0] S00_AXI_AWCACHE
   .S00_AXI_AWPROT(3'b0),              // input wire [2 : 0] S00_AXI_AWPROT
   .S00_AXI_AWQOS(4'b0),                // input wire [3 : 0] S00_AXI_AWQOS
   .S00_AXI_AWVALID(S00_AXI_AWVALID),            // input wire S00_AXI_AWVALID
   .S00_AXI_AWREADY(S00_AXI_AWREADY),            // output wire S00_AXI_AWREADY
   .S00_AXI_WDATA(S00_AXI_WDATA),                // input wire [511 : 0] S00_AXI_WDATA
   .S00_AXI_WSTRB(S00_AXI_WSTRB),                // input wire [63 : 0] S00_AXI_WSTRB
   .S00_AXI_WLAST(S00_AXI_WLAST),                // input wire S00_AXI_WLAST
   .S00_AXI_WVALID(S00_AXI_WVALID),              // input wire S00_AXI_WVALID
   .S00_AXI_WREADY(S00_AXI_WREADY),              // output wire S00_AXI_WREADY
   .S00_AXI_BID(S00_AXI_BID),                    // output wire [0 : 0] S00_AXI_BID
   .S00_AXI_BRESP(S00_AXI_BRESP),                // output wire [1 : 0] S00_AXI_BRESP
   .S00_AXI_BVALID(S00_AXI_BVALID),              // output wire S00_AXI_BVALID
   .S00_AXI_BREADY(S00_AXI_BREADY),              // input wire S00_AXI_BREADY
   .S00_AXI_ARID(S00_AXI_ARID),                  // input wire [0 : 0] S00_AXI_ARID
   .S00_AXI_ARADDR(S00_AXI_ARADDR),              // input wire [31 : 0] S00_AXI_ARADDR
   .S00_AXI_ARLEN(S00_AXI_ARLEN),                // input wire [7 : 0] S00_AXI_ARLEN
   .S00_AXI_ARSIZE(S00_AXI_ARSIZE),              // input wire [2 : 0] S00_AXI_ARSIZE
   .S00_AXI_ARBURST(S00_AXI_ARBURST),            // input wire [1 : 0] S00_AXI_ARBURST
   .S00_AXI_ARLOCK(1'b0),              // input wire S00_AXI_ARLOCK
   .S00_AXI_ARCACHE(4'b0),            // input wire [3 : 0] S00_AXI_ARCACHE
   .S00_AXI_ARPROT(3'b0),              // input wire [2 : 0] S00_AXI_ARPROT
   .S00_AXI_ARQOS(4'b0),                // input wire [3 : 0] S00_AXI_ARQOS
   .S00_AXI_ARVALID(S00_AXI_ARVALID),            // input wire S00_AXI_ARVALID
   .S00_AXI_ARREADY(S00_AXI_ARREADY),            // output wire S00_AXI_ARREADY
   .S00_AXI_RID(S00_AXI_RID),                    // output wire [0 : 0] S00_AXI_RID
   .S00_AXI_RDATA(S00_AXI_RDATA),                // output wire [511 : 0] S00_AXI_RDATA
   .S00_AXI_RRESP(S00_AXI_RRESP),                // output wire [1 : 0] S00_AXI_RRESP
   .S00_AXI_RLAST(S00_AXI_RLAST),                // output wire S00_AXI_RLAST
   .S00_AXI_RVALID(S00_AXI_RVALID),              // output wire S00_AXI_RVALID
   .S00_AXI_RREADY(S00_AXI_RREADY),              // input wire S00_AXI_RREADY
   .S01_AXI_ARESET_OUT_N(),  // output wire S01_AXI_ARESET_OUT_N
   .S01_AXI_ACLK(S_AXI_ACLK),                  // input wire S01_AXI_ACLK
   .S01_AXI_AWID(S01_AXI_AWID),                  // input wire [0 : 0] S01_AXI_AWID
   .S01_AXI_AWADDR(S01_AXI_AWADDR),              // input wire [31 : 0] S01_AXI_AWADDR
   .S01_AXI_AWLEN(S01_AXI_AWLEN),                // input wire [7 : 0] S01_AXI_AWLEN
   .S01_AXI_AWSIZE(S01_AXI_AWSIZE),              // input wire [2 : 0] S01_AXI_AWSIZE
   .S01_AXI_AWBURST(S01_AXI_AWBURST),            // input wire [1 : 0] S01_AXI_AWBURST
   .S01_AXI_AWLOCK(1'b0),              // input wire S01_AXI_AWLOCK
   .S01_AXI_AWCACHE(4'b0),            // input wire [3 : 0] S01_AXI_AWCACHE
   .S01_AXI_AWPROT(3'b0),              // input wire [2 : 0] S01_AXI_AWPROT
   .S01_AXI_AWQOS(4'b0),                // input wire [3 : 0] S01_AXI_AWQOS
   .S01_AXI_AWVALID(S01_AXI_AWVALID),            // input wire S01_AXI_AWVALID
   .S01_AXI_AWREADY(S01_AXI_AWREADY),            // output wire S01_AXI_AWREADY
   .S01_AXI_WDATA(S01_AXI_WDATA),                // input wire [511 : 0] S01_AXI_WDATA
   .S01_AXI_WSTRB(S01_AXI_WSTRB),                // input wire [63 : 0] S01_AXI_WSTRB
   .S01_AXI_WLAST(S01_AXI_WLAST),                // input wire S01_AXI_WLAST
   .S01_AXI_WVALID(S01_AXI_WVALID),              // input wire S01_AXI_WVALID
   .S01_AXI_WREADY(S01_AXI_WREADY),              // output wire S01_AXI_WREADY
   .S01_AXI_BID(S01_AXI_BID),                    // output wire [0 : 0] S01_AXI_BID
   .S01_AXI_BRESP(S01_AXI_BRESP),                // output wire [1 : 0] S01_AXI_BRESP
   .S01_AXI_BVALID(S01_AXI_BVALID),              // output wire S01_AXI_BVALID
   .S01_AXI_BREADY(S01_AXI_BREADY),              // input wire S01_AXI_BREADY
   .S01_AXI_ARID(S01_AXI_ARID),                  // input wire [0 : 0] S01_AXI_ARID
   .S01_AXI_ARADDR(S01_AXI_ARADDR),              // input wire [31 : 0] S01_AXI_ARADDR
   .S01_AXI_ARLEN(S01_AXI_ARLEN),                // input wire [7 : 0] S01_AXI_ARLEN
   .S01_AXI_ARSIZE(S01_AXI_ARSIZE),              // input wire [2 : 0] S01_AXI_ARSIZE
   .S01_AXI_ARBURST(S01_AXI_ARBURST),            // input wire [1 : 0] S01_AXI_ARBURST
   .S01_AXI_ARLOCK(1'b0),              // input wire S01_AXI_ARLOCK
   .S01_AXI_ARCACHE(4'b0),            // input wire [3 : 0] S01_AXI_ARCACHE
   .S01_AXI_ARPROT(3'b0),              // input wire [2 : 0] S01_AXI_ARPROT
   .S01_AXI_ARQOS(4'b0),                // input wire [3 : 0] S01_AXI_ARQOS
   .S01_AXI_ARVALID(S01_AXI_ARVALID),            // input wire S01_AXI_ARVALID
   .S01_AXI_ARREADY(S01_AXI_ARREADY),            // output wire S01_AXI_ARREADY
   .S01_AXI_RID(S01_AXI_RID),                    // output wire [0 : 0] S01_AXI_RID
   .S01_AXI_RDATA(S01_AXI_RDATA),                // output wire [511 : 0] S01_AXI_RDATA
   .S01_AXI_RRESP(S01_AXI_RRESP),                // output wire [1 : 0] S01_AXI_RRESP
   .S01_AXI_RLAST(S01_AXI_RLAST),                // output wire S01_AXI_RLAST
   .S01_AXI_RVALID(S01_AXI_RVALID),              // output wire S01_AXI_RVALID
   .S01_AXI_RREADY(S01_AXI_RREADY),              // input wire S01_AXI_RREADY
   .M00_AXI_ARESET_OUT_N(),  // output wire M00_AXI_ARESET_OUT_N
   .M00_AXI_ACLK(M00_AXI_ACLK),                  // input wire M00_AXI_ACLK
   .M00_AXI_AWID(M00_AXI_AWID),                  // output wire [3 : 0] M00_AXI_AWID
   .M00_AXI_AWADDR(M00_AXI_AWADDR),              // output wire [31 : 0] M00_AXI_AWADDR
   .M00_AXI_AWLEN(M00_AXI_AWLEN),                // output wire [7 : 0] M00_AXI_AWLEN
   .M00_AXI_AWSIZE(M00_AXI_AWSIZE),              // output wire [2 : 0] M00_AXI_AWSIZE
   .M00_AXI_AWBURST(M00_AXI_AWBURST),            // output wire [1 : 0] M00_AXI_AWBURST
   .M00_AXI_AWLOCK(),              // output wire M00_AXI_AWLOCK
   .M00_AXI_AWCACHE(),            // output wire [3 : 0] M00_AXI_AWCACHE
   .M00_AXI_AWPROT(),              // output wire [2 : 0] M00_AXI_AWPROT
   .M00_AXI_AWQOS(),                // output wire [3 : 0] M00_AXI_AWQOS
   .M00_AXI_AWVALID(M00_AXI_AWVALID),            // output wire M00_AXI_AWVALID
   .M00_AXI_AWREADY(M00_AXI_AWREADY),            // input wire M00_AXI_AWREADY
   .M00_AXI_WDATA(M00_AXI_WDATA),                // output wire [511 : 0] M00_AXI_WDATA
   .M00_AXI_WSTRB(M00_AXI_WSTRB),                // output wire [63 : 0] M00_AXI_WSTRB
   .M00_AXI_WLAST(M00_AXI_WLAST),                // output wire M00_AXI_WLAST
   .M00_AXI_WVALID(M00_AXI_WVALID),              // output wire M00_AXI_WVALID
   .M00_AXI_WREADY(M00_AXI_WREADY),              // input wire M00_AXI_WREADY
   .M00_AXI_BID(M00_AXI_BID),                    // input wire [3 : 0] M00_AXI_BID
   .M00_AXI_BRESP(M00_AXI_BRESP),                // input wire [1 : 0] M00_AXI_BRESP
   .M00_AXI_BVALID(M00_AXI_BVALID),              // input wire M00_AXI_BVALID
   .M00_AXI_BREADY(M00_AXI_BREADY),              // output wire M00_AXI_BREADY
   .M00_AXI_ARID(M00_AXI_ARID),                  // output wire [3 : 0] M00_AXI_ARID
   .M00_AXI_ARADDR(M00_AXI_ARADDR),              // output wire [31 : 0] M00_AXI_ARADDR
   .M00_AXI_ARLEN(M00_AXI_ARLEN),                // output wire [7 : 0] M00_AXI_ARLEN
   .M00_AXI_ARSIZE(M00_AXI_ARSIZE),              // output wire [2 : 0] M00_AXI_ARSIZE
   .M00_AXI_ARBURST(M00_AXI_ARBURST),            // output wire [1 : 0] M00_AXI_ARBURST
   .M00_AXI_ARLOCK(),              // output wire M00_AXI_ARLOCK
   .M00_AXI_ARCACHE(),            // output wire [3 : 0] M00_AXI_ARCACHE
   .M00_AXI_ARPROT(),              // output wire [2 : 0] M00_AXI_ARPROT
   .M00_AXI_ARQOS(),                // output wire [3 : 0] M00_AXI_ARQOS
   .M00_AXI_ARVALID(M00_AXI_ARVALID),            // output wire M00_AXI_ARVALID
   .M00_AXI_ARREADY(M00_AXI_ARREADY),            // input wire M00_AXI_ARREADY
   .M00_AXI_RID(M00_AXI_RID),                    // input wire [3 : 0] M00_AXI_RID
   .M00_AXI_RDATA(M00_AXI_RDATA),                // input wire [511 : 0] M00_AXI_RDATA
   .M00_AXI_RRESP(M00_AXI_RRESP),                // input wire [1 : 0] M00_AXI_RRESP
   .M00_AXI_RLAST(M00_AXI_RLAST),                // input wire M00_AXI_RLAST
   .M00_AXI_RVALID(M00_AXI_RVALID),              // input wire M00_AXI_RVALID
   .M00_AXI_RREADY(M00_AXI_RREADY)              // output wire M00_AXI_RREADY
 );
 
  axi_datamover_1 ht_data_mover(
   .m_axi_mm2s_aclk(S_AXI_ACLK),                        // input wire m_axi_mm2s_aclk
   .m_axi_mm2s_aresetn(S_ARESETN),                  // input wire m_axi_mm2s_aresetn
   .mm2s_err(),                                      // output wire mm2s_err
   .m_axis_mm2s_cmdsts_aclk(S_AXI_ACLK),        // input wire m_axis_mm2s_cmdsts_aclk
   .m_axis_mm2s_cmdsts_aresetn(S_ARESETN),  // input wire m_axis_mm2s_cmdsts_aresetn
   .s_axis_mm2s_cmd_tvalid(ht_s_axis_read_cmd_tvalid),          // input wire s_axis_mm2s_cmd_tvalid
   .s_axis_mm2s_cmd_tready(ht_s_axis_read_cmd_tready),          // output wire s_axis_mm2s_cmd_tready
   .s_axis_mm2s_cmd_tdata(ht_s_axis_read_cmd_tdata),            // input wire [71 : 0] s_axis_mm2s_cmd_tdata
   .m_axis_mm2s_sts_tvalid(ht_m_axis_read_sts_tvalid),          // output wire m_axis_mm2s_sts_tvalid
   .m_axis_mm2s_sts_tready(ht_m_axis_read_sts_tready),          // input wire m_axis_mm2s_sts_tready
   .m_axis_mm2s_sts_tdata(ht_m_axis_read_sts_tdata),            // output wire [7 : 0] m_axis_mm2s_sts_tdata
   .m_axis_mm2s_sts_tkeep(),            // output wire [0 : 0] m_axis_mm2s_sts_tkeep
   .m_axis_mm2s_sts_tlast(),            // output wire m_axis_mm2s_sts_tlast
   .m_axi_mm2s_arid(S00_AXI_ARID_x),                        // output wire [3 : 0] m_axi_mm2s_arid
   .m_axi_mm2s_araddr(S00_AXI_ARADDR),                    // output wire [31 : 0] m_axi_mm2s_araddr
   .m_axi_mm2s_arlen(S00_AXI_ARLEN),                      // output wire [7 : 0] m_axi_mm2s_arlen
   .m_axi_mm2s_arsize(S00_AXI_ARSIZE),                    // output wire [2 : 0] m_axi_mm2s_arsize
   .m_axi_mm2s_arburst(S00_AXI_ARBURST),                  // output wire [1 : 0] m_axi_mm2s_arburst
   .m_axi_mm2s_arprot(),                    // output wire [2 : 0] m_axi_mm2s_arprot
   .m_axi_mm2s_arcache(),                  // output wire [3 : 0] m_axi_mm2s_arcache
   .m_axi_mm2s_aruser(),                    // output wire [3 : 0] m_axi_mm2s_aruser
   .m_axi_mm2s_arvalid(S00_AXI_ARVALID),                  // output wire m_axi_mm2s_arvalid
   .m_axi_mm2s_arready(S00_AXI_ARREADY),                  // input wire m_axi_mm2s_arready
   .m_axi_mm2s_rdata(S00_AXI_RDATA),                      // input wire [511 : 0] m_axi_mm2s_rdata
   .m_axi_mm2s_rresp(S00_AXI_RRESP),                      // input wire [1 : 0] m_axi_mm2s_rresp
   .m_axi_mm2s_rlast(S00_AXI_RLAST),                      // input wire m_axi_mm2s_rlast
   .m_axi_mm2s_rvalid(S00_AXI_RVALID),                    // input wire m_axi_mm2s_rvalid
   .m_axi_mm2s_rready(S00_AXI_RREADY),                    // output wire m_axi_mm2s_rready
   .m_axis_mm2s_tdata(ht_m_axis_read_tdata),                    // output wire [511 : 0] m_axis_mm2s_tdata
   .m_axis_mm2s_tkeep(ht_m_axis_read_tkeep),                    // output wire [63 : 0] m_axis_mm2s_tkeep
   .m_axis_mm2s_tlast(ht_m_axis_read_tlast),                    // output wire m_axis_mm2s_tlast
   .m_axis_mm2s_tvalid(ht_m_axis_read_tvalid),                  // output wire m_axis_mm2s_tvalid
   .m_axis_mm2s_tready(ht_m_axis_read_tready),                  // input wire m_axis_mm2s_tready
   .m_axi_s2mm_aclk(S_AXI_ACLK),                        // input wire m_axi_s2mm_aclk
   .m_axi_s2mm_aresetn(S_ARESETN),                  // input wire m_axi_s2mm_aresetn
   .s2mm_err(),                                      // output wire s2mm_err
   .m_axis_s2mm_cmdsts_awclk(S_AXI_ACLK),      // input wire m_axis_s2mm_cmdsts_awclk
   .m_axis_s2mm_cmdsts_aresetn(S_ARESETN),  // input wire m_axis_s2mm_cmdsts_aresetn
   .s_axis_s2mm_cmd_tvalid(ht_s_axis_write_cmd_tvalid),          // input wire s_axis_s2mm_cmd_tvalid
   .s_axis_s2mm_cmd_tready(ht_s_axis_write_cmd_tready),          // output wire s_axis_s2mm_cmd_tready
   .s_axis_s2mm_cmd_tdata(ht_s_axis_write_cmd_tdata),            // input wire [71 : 0] s_axis_s2mm_cmd_tdata
   .m_axis_s2mm_sts_tvalid(ht_m_axis_write_sts_tvalid),          // output wire m_axis_s2mm_sts_tvalid
   .m_axis_s2mm_sts_tready(ht_m_axis_write_sts_tready),          // input wire m_axis_s2mm_sts_tready
   .m_axis_s2mm_sts_tdata(ht_m_axis_write_sts_tdata),            // output wire [7 : 0] m_axis_s2mm_sts_tdata
   .m_axis_s2mm_sts_tkeep(),            // output wire [0 : 0] m_axis_s2mm_sts_tkeep
   .m_axis_s2mm_sts_tlast(),            // output wire m_axis_s2mm_sts_tlast
   .m_axi_s2mm_awid(S00_AXI_AWID_x),                        // output wire [3 : 0] m_axi_s2mm_awid
   .m_axi_s2mm_awaddr(S00_AXI_AWADDR),                    // output wire [31 : 0] m_axi_s2mm_awaddr
   .m_axi_s2mm_awlen(S00_AXI_AWLEN),                      // output wire [7 : 0] m_axi_s2mm_awlen
   .m_axi_s2mm_awsize(S00_AXI_AWSIZE),                    // output wire [2 : 0] m_axi_s2mm_awsize
   .m_axi_s2mm_awburst(S00_AXI_AWBURST),                  // output wire [1 : 0] m_axi_s2mm_awburst
   .m_axi_s2mm_awprot(),                    // output wire [2 : 0] m_axi_s2mm_awprot
   .m_axi_s2mm_awcache(),                  // output wire [3 : 0] m_axi_s2mm_awcache
   .m_axi_s2mm_awuser(),                    // output wire [3 : 0] m_axi_s2mm_awuser
   .m_axi_s2mm_awvalid(S00_AXI_AWVALID),                  // output wire m_axi_s2mm_awvalid
   .m_axi_s2mm_awready(S00_AXI_AWREADY),                  // input wire m_axi_s2mm_awready
   .m_axi_s2mm_wdata(S00_AXI_WDATA),                      // output wire [511 : 0] m_axi_s2mm_wdata
   .m_axi_s2mm_wstrb(S00_AXI_WSTRB),                      // output wire [63 : 0] m_axi_s2mm_wstrb
   .m_axi_s2mm_wlast(S00_AXI_WLAST),                      // output wire m_axi_s2mm_wlast
   .m_axi_s2mm_wvalid(S00_AXI_WVALID),                    // output wire m_axi_s2mm_wvalid
   .m_axi_s2mm_wready(S00_AXI_WREADY),                    // input wire m_axi_s2mm_wready
   .m_axi_s2mm_bresp(S00_AXI_BRESP),                      // input wire [1 : 0] m_axi_s2mm_bresp
   .m_axi_s2mm_bvalid(S00_AXI_BVALID),                    // input wire m_axi_s2mm_bvalid
   .m_axi_s2mm_bready(S00_AXI_BREADY),                    // output wire m_axi_s2mm_bready
   .s_axis_s2mm_tdata(ht_s_axis_write_tdata),                    // input wire [511 : 0] s_axis_s2mm_tdata
   .s_axis_s2mm_tkeep(ht_s_axis_write_tkeep),                    // input wire [63 : 0] s_axis_s2mm_tkeep
   .s_axis_s2mm_tlast(ht_s_axis_write_tlast),                    // input wire s_axis_s2mm_tlast
   .s_axis_s2mm_tvalid(ht_s_axis_write_tvalid),                  // input wire s_axis_s2mm_tvalid
   .s_axis_s2mm_tready(ht_s_axis_write_tready)                  // output wire s_axis_s2mm_tready
 );
 
  axi_datamover_1 vs_data_mover (
     .m_axi_mm2s_aclk(S_AXI_ACLK),// : IN STD_LOGIC;
     .m_axi_mm2s_aresetn(S_ARESETN), //: IN STD_LOGIC;
     .mm2s_err(), //: OUT STD_LOGIC;
     .m_axis_mm2s_cmdsts_aclk(S_AXI_ACLK), //: IN STD_LOGIC;
     .m_axis_mm2s_cmdsts_aresetn(S_ARESETN), //: IN STD_LOGIC;
     .s_axis_mm2s_cmd_tvalid(vs_s_axis_read_cmd_tvalid), //: IN STD_LOGIC;
     .s_axis_mm2s_cmd_tready(vs_s_axis_read_cmd_tready), //: OUT STD_LOGIC;
     .s_axis_mm2s_cmd_tdata(vs_s_axis_read_cmd_tdata), //: IN STD_LOGIC_VECTOR(71 DOWNTO 0);
     .m_axis_mm2s_sts_tvalid(vs_m_axis_read_sts_tvalid), //: OUT STD_LOGIC;
     .m_axis_mm2s_sts_tready(vs_m_axis_read_sts_tready), //: IN STD_LOGIC;
     .m_axis_mm2s_sts_tdata(vs_m_axis_read_sts_tdata), //: OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
     .m_axis_mm2s_sts_tkeep(), //: OUT STD_LOGIC_VECTOR(0 DOWNTO 0);
     .m_axis_mm2s_sts_tlast(), //: OUT STD_LOGIC;
     .m_axi_mm2s_arid(S01_AXI_ARID_x), //: OUT STD_LOGIC_VECTOR(3 DOWNTO 0);
     .m_axi_mm2s_araddr(S01_AXI_ARADDR), //: OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
     .m_axi_mm2s_arlen(S01_AXI_ARLEN), //: OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
     .m_axi_mm2s_arsize(S01_AXI_ARSIZE), //: OUT STD_LOGIC_VECTOR(2 DOWNTO 0);
     .m_axi_mm2s_arburst(S01_AXI_ARBURST), //: OUT STD_LOGIC_VECTOR(1 DOWNTO 0);
     .m_axi_mm2s_arprot(), //: OUT STD_LOGIC_VECTOR(2 DOWNTO 0);
     .m_axi_mm2s_arcache(), //: OUT STD_LOGIC_VECTOR(3 DOWNTO 0);
     .m_axi_mm2s_aruser(), //: OUT STD_LOGIC_VECTOR(3 DOWNTO 0);
     .m_axi_mm2s_arvalid(S01_AXI_ARVALID), //: OUT STD_LOGIC;
     .m_axi_mm2s_arready(S01_AXI_ARREADY), //: IN STD_LOGIC;
     .m_axi_mm2s_rdata(S01_AXI_RDATA), //: IN STD_LOGIC_VECTOR(511 DOWNTO 0);
     .m_axi_mm2s_rresp(S01_AXI_RRESP), //: IN STD_LOGIC_VECTOR(1 DOWNTO 0);
     .m_axi_mm2s_rlast(S01_AXI_RLAST), //: IN STD_LOGIC;
     .m_axi_mm2s_rvalid(S01_AXI_RVALID), //: IN STD_LOGIC;
     .m_axi_mm2s_rready(S01_AXI_RREADY), //: OUT STD_LOGIC;
     .m_axis_mm2s_tdata(vs_m_axis_read_tdata), //: OUT STD_LOGIC_VECTOR(511 DOWNTO 0);
     .m_axis_mm2s_tkeep(vs_m_axis_read_tkeep), //: OUT STD_LOGIC_VECTOR(63 DOWNTO 0);
     .m_axis_mm2s_tlast(vs_m_axis_read_tlast), //: OUT STD_LOGIC;
     .m_axis_mm2s_tvalid(vs_m_axis_read_tvalid), //: OUT STD_LOGIC;
     .m_axis_mm2s_tready(vs_m_axis_read_tready), //: IN STD_LOGIC;
     .m_axi_s2mm_aclk(S_AXI_ACLK), //: IN STD_LOGIC;
     .m_axi_s2mm_aresetn(S_ARESETN), //: IN STD_LOGIC;
     .s2mm_err(), //: OUT STD_LOGIC;
     .m_axis_s2mm_cmdsts_awclk(S_AXI_ACLK), //: IN STD_LOGIC;
     .m_axis_s2mm_cmdsts_aresetn(S_ARESETN), //: IN STD_LOGIC;
     .s_axis_s2mm_cmd_tvalid(vs_s_axis_write_cmd_tvalid), //: IN STD_LOGIC;
     .s_axis_s2mm_cmd_tready(vs_s_axis_write_cmd_tready), //: OUT STD_LOGIC;
     .s_axis_s2mm_cmd_tdata(vs_s_axis_write_cmd_tdata), //: IN STD_LOGIC_VECTOR(71 DOWNTO 0);
     .m_axis_s2mm_sts_tvalid(vs_m_axis_write_sts_tvalid), //: OUT STD_LOGIC;
     .m_axis_s2mm_sts_tready(vs_m_axis_write_sts_tready), //: IN STD_LOGIC;
     .m_axis_s2mm_sts_tdata(vs_m_axis_write_sts_tdata), //: OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
     .m_axis_s2mm_sts_tkeep(), //: OUT STD_LOGIC_VECTOR(3 DOWNTO 0);
     .m_axis_s2mm_sts_tlast(), //: OUT STD_LOGIC;
     .m_axi_s2mm_awid(S01_AXI_AWID_x), //: OUT STD_LOGIC_VECTOR(3 DOWNTO 0);
     .m_axi_s2mm_awaddr(S01_AXI_AWADDR), //: OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
     .m_axi_s2mm_awlen(S01_AXI_AWLEN), //: OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
     .m_axi_s2mm_awsize(S01_AXI_AWSIZE), //: OUT STD_LOGIC_VECTOR(2 DOWNTO 0);
     .m_axi_s2mm_awburst(S01_AXI_AWBURST), //: OUT STD_LOGIC_VECTOR(1 DOWNTO 0);
     .m_axi_s2mm_awprot(), //: OUT STD_LOGIC_VECTOR(2 DOWNTO 0);
     .m_axi_s2mm_awcache(), //: OUT STD_LOGIC_VECTOR(3 DOWNTO 0);
     .m_axi_s2mm_awuser(), //: OUT STD_LOGIC_VECTOR(3 DOWNTO 0);
     .m_axi_s2mm_awvalid(S01_AXI_AWVALID), //: OUT STD_LOGIC;
     .m_axi_s2mm_awready(S01_AXI_AWREADY), //: IN STD_LOGIC;
     .m_axi_s2mm_wdata(S01_AXI_WDATA), //: OUT STD_LOGIC_VECTOR(511 DOWNTO 0);
     .m_axi_s2mm_wstrb(S01_AXI_WSTRB), //: OUT STD_LOGIC_VECTOR(63 DOWNTO 0);
     .m_axi_s2mm_wlast(S01_AXI_WLAST), //: OUT STD_LOGIC;
     .m_axi_s2mm_wvalid(S01_AXI_WVALID), //: OUT STD_LOGIC;
     .m_axi_s2mm_wready(S01_AXI_WREADY), //: IN STD_LOGIC;
     .m_axi_s2mm_bresp(S01_AXI_BRESP), //: IN STD_LOGIC_VECTOR(1 DOWNTO 0);
     .m_axi_s2mm_bvalid(S01_AXI_BVALID), //: IN STD_LOGIC;
     .m_axi_s2mm_bready(S01_AXI_BREADY), //: OUT STD_LOGIC;
     .s_axis_s2mm_tdata(vs_s_axis_write_tdata), //: IN STD_LOGIC_VECTOR(511 DOWNTO 0);
     .s_axis_s2mm_tkeep(vs_s_axis_write_tkeep), //: IN STD_LOGIC_VECTOR(63 DOWNTO 0);
     .s_axis_s2mm_tlast(vs_s_axis_write_tlast), //: IN STD_LOGIC;
     .s_axis_s2mm_tvalid(vs_s_axis_write_tvalid), //: IN STD_LOGIC;
     .s_axis_s2mm_tready(vs_s_axis_write_tready) //: OUT STD_LOGIC;
 );
endmodule
