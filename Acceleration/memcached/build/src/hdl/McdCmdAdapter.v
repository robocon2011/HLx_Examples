`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: Xilinx
// Engineer: Lisa Liu
// 
// Create Date: 03/06/2014 10:22:53 AM
// Design Name: 
// Module Name: McdCmdAdapter
// Project Name: 
// Target Devices: VC709
// Tool Versions: Vivado13.4
// Description: convert the address for 512bits in memcached cmd into sata lba and sectorCnt
// 
// Dependencies 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////

module McdCmdAdapter(
input clk,
input nReset,
//memcached side signals
input[45:0] cmd_data, // bit0: read/write (0: read, 1: write), bit 32..1: address, bit 45:33: count of 64 bit words
input cmd_valid,
output cmd_ready,
//ssd side signals
output [2:0] cmd,
output cmd_en,
output [47:0] lba,
output [15:0] sectorcnt,
input cmd_success,
input cmd_failed,
input ncq_idle,
input fin_read_sig,
//signals to MemWrDataConv
//since each command can only contain one num_words info for either read or write SSD operation
output[15:0] num_words, //number of 32-bit words to MemWrDataConv and MemRdDataConv
output rd_num_words_en, //pulse signal to indicate a new num_words coming
output wr_num_words_en, //pulse signal to indicate a new num_words coming

//debug signa;
output vio_reset
//output cmd_valid_dly1_de, 
//output cmd_valid_dly2_de,
//output cmd_ready_in1_de, 
//output cmd_ready_in2_de
);

wire [45:0] cmd_data_dly1;
wire cmd_valid_dly1, cmd_valid_dly2;
wire cmd_ready_in1, cmd_ready_in2;
wire[13:0] num_word32;
wire [2:0] cmd_int;
wire [61:0] int_bus, int_bus_dly1;

wire is_write;
wire [34:0] lba_int;
wire [7:0] sectorcnt_int;

reg [15:0] num_words_r;
reg rd_num_words_en_r, wr_num_words_en_r;
reg cmd_en_r1; //latch the value of cmd_en. 

//assign cmd_valid_dly1_de = cmd_valid_dly1; 
//assign cmd_valid_dly2_de = cmd_valid_dly2;
//assign cmd_ready_in1_de = cmd_ready_in1;
//assign cmd_ready_in2_de = cmd_ready_in2;

always @(posedge clk)
    if (~nReset)
        cmd_en_r1 <= 1'b0;
    else
        cmd_en_r1 <= cmd_en;
    

//register input
AxiRegSlice #(.N(46)) 
 cmd_input_reg(
    // system signals
    .clk(clk),
    .nReset(nReset),
    // slave side
    .s_data(cmd_data),
    .s_valid(cmd_valid),
    .s_ready(cmd_ready),
    // master side
    .m_data(cmd_data_dly1),
    .m_valid(cmd_valid_dly1),
    .m_ready(cmd_ready_in1)
);
assign is_write = cmd_data_dly1[0];
assign lba_int = {4'b0, cmd_data_dly1[28:1], 3'b000}; //align cmd arddress to pages, wich is 8 sectors, and drop bit 32, the msb, to avoid address overflow
assign sectorcnt_int = (cmd_data_dly1[38:33] == 0)? {1'b0, cmd_data_dly1[45:39]}: {1'b0, cmd_data_dly1[45:39]}+1;
assign num_word32 = {cmd_data_dly1[45:33], 1'b0};
assign cmd_int = (is_write)?{3'b010}: {3'b001};
assign int_bus[2:0] = cmd_int;
assign int_bus[37:3] = lba_int;
assign int_bus[45:38] = sectorcnt_int;
assign int_bus[59:46] = num_word32;
assign int_bus[60] = is_write;
assign int_bus[61] = ~is_write;

//register input
AxiRegSlice #(.N(62)) 
 cmd_output_reg(
    // system signals
    .clk(clk),
    .nReset(nReset),
    // slave side
    .s_data(int_bus),
    .s_valid(cmd_valid_dly1),
    .s_ready(cmd_ready_in1),
    // master side
    .m_data(int_bus_dly1),
    .m_valid(cmd_valid_dly2),
    .m_ready(cmd_ready_in2)
);
//when ssd_hba is in idle state ncq_idle is asserted, therefore use ncq_idle to indicate ssd_hba is ready. 
//But in case of command failure, re_trans_r goes low, then command is executed again
assign cmd_ready_in2 = ncq_idle & fin_read_sig & ~cmd_en_r1;//ncd_idle keeps high for another cycle after cmd_en is asserted.

//issue cmd, cmd_en, lba, sectorcnt to ssd_hba
assign cmd = int_bus_dly1[2:0];
assign cmd_en = cmd_valid_dly2 & cmd_ready_in2;
assign lba = {13'b0, int_bus_dly1[37:3]};
assign sectorcnt = {8'b0, int_bus_dly1[45:38]};

//generate num_words and rd_num_words_en or wr_num_words_en pulse signal
always @(posedge clk)
    if (~nReset) begin
        rd_num_words_en_r <= 1'b0;
        wr_num_words_en_r <= 1'b0;
        num_words_r <= 0;
    end
    else begin
        num_words_r <= {2'b0, int_bus_dly1[59:46]};
        rd_num_words_en_r <= int_bus_dly1[61] & cmd_valid_dly2 & cmd_ready_in2;
        wr_num_words_en_r <= int_bus_dly1[60] & cmd_valid_dly2 & cmd_ready_in2;
    end

assign num_words = num_words_r;
assign rd_num_words_en = rd_num_words_en_r;
assign wr_num_words_en = wr_num_words_en_r;

//chipscope debugging
/*
 reg [255:0] data;
reg [31:0]  trig0;
wire [35:0] control0, control1;
        
 chipscope_icon icon0
(
    .CONTROL0 (control0),
    .CONTROL1 (control1)
);

chipscope_ila ila0
(
    .CLK     (clk),
    .CONTROL (control0),
    .TRIG0   (trig0),
    .DATA    (data)
);
chipscope_vio vio0
(
    .CONTROL(control1),
    .ASYNC_OUT(vio_reset)
);
 
 always @(posedge clk) begin
  data[2:0] <= cmd;
  data[3] <= cmd_en;
  data[51:4] <= lba;
  data[67:52] <= sectorcnt;
  data[68] <= cmd_success;
  data[69] <= cmd_failed;
  data[70] <= ncq_idle;
  data[71] <= fin_read_sig;
  data[72] <= rd_num_words_en;
  data[73] <= wr_num_words_en;
  data[89:74] <= num_words_r;
  data[90] <= re_trans_r;
  data[91] <= cmd_valid_dly1;
  data[92] <= cmd_ready_in1;
  data[93] <= cmd_valid_dly2;
  data[94] <= cmd_ready_in2;
  data[95] <= cmd_valid;
  data[96] <= cmd_ready;
  data[142:97] <= cmd_data;
 
  trig0[0] <= cmd_en;
  trig0[1] <= cmd_success;
  trig0[2] <= cmd_failed;
  trig0[3] <= ncq_idle;
  trig0[4] <= fin_read_sig;
  trig0[5] <= rd_num_words_en;
  trig0[6] <= wr_num_words_en;
  trig0[7] <= cmd_valid_dly1;
  trig0[8] <= cmd_ready_in1;
  trig0[9] <= cmd_valid_dly2;
  trig0[10] <= cmd_ready_in2;
  trig0[11] <= cmd_valid;
  trig0[12] <= cmd_ready;
 end*/
endmodule
