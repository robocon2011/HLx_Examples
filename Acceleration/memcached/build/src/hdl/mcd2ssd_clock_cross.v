`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 03/11/2014 05:28:41 PM
// Design Name: 
// Module Name: mcd2ssd_clock_cross
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
module mcd2ssd_clock_cross(
input clk156,
input clk150,
input nReset156,
input nReset150,
//clk156 signals
input [44:0] clk156_cmd_dramRdData_data,
input clk156_cmd_dramRdData_valid,
output clk156_cmd_dramRdData_ready,
input[44:0] clk156_cmd_dramWrData_data,
input clk156_cmd_dramWrData_valid,
output clk156_cmd_dramWrData_ready,
output [63:0] clk156_dramRdData_data,
output clk156_dramRdData_valid,
input clk156_dramRdData_ready,
input [63:0] clk156_dramWrData_data,
input clk156_dramWrData_valid,
output clk156_dramWrData_ready,

//clk150 signals
output [44:0] clk150_cmd_dramRdData_data,
output clk150_cmd_dramRdData_valid,
input clk150_cmd_dramRdData_ready,
output [44:0] clk150_cmd_dramWrData_data,
output clk150_cmd_dramWrData_valid,
input clk150_cmd_dramWrData_ready,
input [31:0] clk150_dramRdData_data,
input clk150_dramRdData_valid,
output clk150_dramRdData_ready,
output [31:0] clk150_dramWrData_data,
output clk150_dramWrData_valid,
input clk150_dramWrData_ready
);

/*wire [47:0] clk150_cmd_dramWrData_data_int;
wire [47:0] clk150_cmd_dramRdData_data_int;

mem_cmd_clock_converter dramWrcmd_clock_converter (
    .s_axis_aclken(1'b1),    // input wire s_axis_aclken
  .m_axis_aclken(1'b1),    // input wire m_axis_aclken
  .s_axis_aresetn(nReset156),  // input wire s_axis_aresetn
  .m_axis_aresetn(nReset150),  // input wire m_axis_aresetn
  .s_axis_aclk(clk156),        // input wire s_axis_aclk
  .s_axis_tvalid(clk156_cmd_dramWrData_valid),    // input wire s_axis_tvalid
  .s_axis_tready(clk156_cmd_dramWrData_ready),    // output wire s_axis_tready
  .s_axis_tdata({3'b0,clk156_cmd_dramWrData_data}),      // input wire [47 : 0] s_axis_tdata
  .m_axis_aclk(clk150),        // input wire m_axis_aclk
  .m_axis_tvalid(clk150_cmd_dramWrData_valid),    // output wire m_axis_tvalid
  .m_axis_tready(clk150_cmd_dramWrData_ready),    // input wire m_axis_tready
  .m_axis_tdata(clk150_cmd_dramWrData_data_int)      // output wire [47 : 0] m_axis_tdata
);
assign clk150_cmd_dramWrData_data = clk150_cmd_dramWrData_data_int[44:0];*/
//write cmd asyn fifo
wire dramWrCmd_asyn_fifo_full,dramWrCmd_asyn_fifo_empty;
wire dramWrCmd_asyn_fifo_wr_en, dramWrCmd_asyn_fifo_rd_en;

asyn_fifo_45 dramWrCmd_asyn_fifo (
  //.wr_rst(~nReset156),        // input wire rst
  .rst(~nReset156),
  .wr_clk(clk156),  // input wire wr_clk
  .rd_clk(clk150),  // input wire rd_clk
  //.rd_rst(~nReset150),
  .din(clk156_cmd_dramWrData_data),        // input wire [63 : 0] din
  .wr_en(dramWrCmd_asyn_fifo_wr_en),    // input wire wr_en
  .rd_en(dramWrCmd_asyn_fifo_rd_en),    // input wire rd_en
  .dout(clk150_cmd_dramWrData_data),      // output wire [31 : 0] dout
  .full(dramWrCmd_asyn_fifo_full),      // output wire full
  .empty(dramWrCmd_asyn_fifo_empty)    // output wire empty
);

assign dramWrCmd_asyn_fifo_wr_en = ~dramWrCmd_asyn_fifo_full & clk156_cmd_dramWrData_valid;
assign clk156_cmd_dramWrData_ready = ~dramWrCmd_asyn_fifo_full;
assign clk150_cmd_dramWrData_valid = ~dramWrCmd_asyn_fifo_empty;
assign dramWrCmd_asyn_fifo_rd_en = ~dramWrCmd_asyn_fifo_empty & clk150_cmd_dramWrData_ready;


/*mem_cmd_clock_converter dramRdcmd_clock_converter (
   .s_axis_aclken(1'b1),    // input wire s_axis_aclken
  .m_axis_aclken(1'b1),    // input wire m_axis_aclken
  
  .s_axis_aresetn(nReset156),  // input wire s_axis_aresetn
  .m_axis_aresetn(nReset150),  // input wire m_axis_aresetn
  .s_axis_aclk(clk156),        // input wire s_axis_aclk
  .s_axis_tvalid(clk156_cmd_dramRdData_valid),    // input wire s_axis_tvalid
  .s_axis_tready(clk156_cmd_dramRdData_ready),    // output wire s_axis_tready
  .s_axis_tdata({3'b0, clk156_cmd_dramRdData_data}),      // input wire [47 : 0] s_axis_tdata
  .m_axis_aclk(clk150),        // input wire m_axis_aclk
  .m_axis_tvalid(clk150_cmd_dramRdData_valid),    // output wire m_axis_tvalid
  .m_axis_tready(clk150_cmd_dramRdData_ready),    // input wire m_axis_tready
  .m_axis_tdata(clk150_cmd_dramRdData_data_int)      // output wire [47 : 0] m_axis_tdata
);
assign clk150_cmd_dramRdData_data = clk150_cmd_dramRdData_data_int[44:0];*/
//read cmd asyn fifo
wire dramRdCmd_asyn_fifo_full, dramRdCmd_asyn_fifo_empty;
wire dramRdCmd_asyn_fifo_wr_en, dramRdCmd_asyn_fifo_rd_en;

asyn_fifo_45 dramRdCmd_asyn_fifo (
  //.wr_rst(~nReset156),        // input wire rst
  .rst(~nReset156),
  .wr_clk(clk156),  // input wire wr_clk
  .rd_clk(clk150),  // input wire rd_clk
  //.rd_rst(~nReset150),
  .din(clk156_cmd_dramRdData_data),        // input wire [63 : 0] din
  .wr_en(dramRdCmd_asyn_fifo_wr_en),    // input wire wr_en
  .rd_en(dramRdCmd_asyn_fifo_rd_en),    // input wire rd_en
  .dout(clk150_cmd_dramRdData_data),      // output wire [31 : 0] dout
  .full(dramRdCmd_asyn_fifo_full),      // output wire full
  .empty(dramRdCmd_asyn_fifo_empty)    // output wire empty
);

assign dramRdCmd_asyn_fifo_wr_en = ~dramRdCmd_asyn_fifo_full & clk156_cmd_dramRdData_valid;
assign clk156_cmd_dramRdData_ready = ~dramRdCmd_asyn_fifo_full;
assign clk150_cmd_dramRdData_valid = ~dramRdCmd_asyn_fifo_empty;
assign dramRdCmd_asyn_fifo_rd_en = ~dramRdCmd_asyn_fifo_empty & clk150_cmd_dramRdData_ready;

wire dramWrData_asyn_fifo_full,dramWrData_asyn_fifo_empty;
wire dramWrData_asyn_fifo_wr_en, dramWrData_asyn_fifo_rd_en;

asyn_fifo_64To32 dramWrData_asyn_fifo (
  .wr_rst(~nReset156),        // input wire rst
  .wr_clk(clk156),  // input wire wr_clk
  .rd_clk(clk150),  // input wire rd_clk
  .rd_rst(~nReset150),
  .din(clk156_dramWrData_data),        // input wire [63 : 0] din
  .wr_en(dramWrData_asyn_fifo_wr_en),    // input wire wr_en
  .rd_en(dramWrData_asyn_fifo_rd_en),    // input wire rd_en
  .dout(clk150_dramWrData_data),      // output wire [31 : 0] dout
  .full(dramWrData_asyn_fifo_full),      // output wire full
  .empty(dramWrData_asyn_fifo_empty)    // output wire empty
);

assign dramWrData_asyn_fifo_wr_en = ~dramWrData_asyn_fifo_full & clk156_dramWrData_valid;
assign clk156_dramWrData_ready = ~dramWrData_asyn_fifo_full;
assign clk150_dramWrData_valid = ~dramWrData_asyn_fifo_empty;
assign dramWrData_asyn_fifo_rd_en = ~dramWrData_asyn_fifo_empty & clk150_dramWrData_ready;

wire dramRdData_asyn_fifo_full, dramRdData_asyn_fifo_empty;
wire dramRdData_asyn_fifo_wr_en, dramRdData_asyn_fifo_rd_en;

asyn_fifo_32To64 dramRdData_asyn_fifo (
  .wr_rst(~nReset150),        // input wire rst
  .wr_clk(clk150),  // input wire wr_clk
  .rd_clk(clk156),  // input wire rd_clk
  .rd_rst(~nReset156),
  .din(clk150_dramRdData_data),        // input wire [31 : 0] din
  .wr_en(dramRdData_asyn_fifo_wr_en),    // input wire wr_en
  .rd_en(dramRdData_asyn_fifo_rd_en),    // input wire rd_en
  .dout(clk156_dramRdData_data),      // output wire [63 : 0] dout
  .full(dramRdData_asyn_fifo_full),      // output wire full
  .empty(dramRdData_asyn_fifo_empty)    // output wire empty
);
assign dramRdData_asyn_fifo_wr_en = ~dramRdData_asyn_fifo_full & clk150_dramRdData_valid;
assign clk150_dramRdData_ready = ~dramRdData_asyn_fifo_full;
assign dramRdData_asyn_fifo_rd_en = ~dramRdData_asyn_fifo_empty & clk156_dramRdData_ready;
assign clk156_dramRdData_valid = ~dramRdData_asyn_fifo_empty;

//chipscope debugging

/*reg [127:0] data;
   reg [15:0]  trig0;
   wire [35:0] control;

  chipscope_icon icon0
     (
      .CONTROL0 (control)
      );

   chipscope_ila ila0
     (
      .CLK     (clk156),
      .CONTROL (control),
      .TRIG0   (trig0),
      .DATA    (data)
      );
      
//test_inf_cmd_wr   
  always @(posedge clk156) begin
    data[63:0] <= clk156_dramWrData_data;
    data[64] <= dramWrData_asyn_fifo_wr_en;
    data[65] <= dramWrData_asyn_fifo_full;
    data[66] <= dramWrData_asyn_fifo_empty;
    //data[98:67] <= clk150_dramWrData_data;
    data[99] <= dramWrData_asyn_fifo_rd_en;
    
    trig0[0] <= nReset156;
    trig0[1] <= nReset150;
    trig0[2] <= dramWrData_asyn_fifo_wr_en;
    trig0[3] <= dramWrData_asyn_fifo_rd_en;
    trig0[4] <= dramWrData_asyn_fifo_full;
    trig0[50] <= dramWrData_asyn_fifo_empty;
  end*/

endmodule
