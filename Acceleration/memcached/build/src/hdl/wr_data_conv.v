`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: Xilinx
// Engineer: Lisa Liu  
// 
// Create Date: 03/10/2014 09:30:40 AM
// Design Name: 
// Module Name: wr_data_conv
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: convert memcached 512 bit memory write path into 32 bit SSD write path 
//              assume clock frequency is 150MHz, the system clock used for SSD controller
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module wr_data_conv(
input clk,
input nReset,
//signals to / from mcd
input [31:0] dramWrData_data,
input dramWrData_valid,
output dramWrData_ready,
//signal to/from sata hba
output [31:0] wdata,
output wdata_en,
input wdata_full,
//signals from McdCmdAdapter indicating how many 32-bit words are expected
input [15:0] num_words,
input wr_num_words_en,
//debug ports
output[1:0] curr_state_r_de,
output [15:0] curr_words_r_de
);

localparam IDLE = 2'd0;
localparam SET_COUNTER = 2'd1;
localparam COMPARE = 2'd2;
localparam PADDING = 2'd3;

//debugging connections
assign curr_state_r_de = curr_state_r;
assign curr_words_r_de = curr_words_r;
 
reg [1:0] curr_state_r;
reg [15:0] num_words_r, curr_words_r;

wire nw_fifo_full_n;
wire nw_fifo_empty_n;
wire nw_fifo_read;
wire[15:0] nw_fifo_dout;

wire [31:0] dramWrData_data_dly1;
wire dramWrData_valid_dly1;
wire dramWrData_ready_in1;
wire [31:0] wdata_int;
wire wdata_en_int, wdata_en_int1;

//store num_words into fifo
reg_fifo #(
    .DATA_BITS(16),
    .DEPTH_BITS(4))
reg_fifo_inst(
    .clk(clk),
    .nReset(nReset),
    .write(wr_num_words_en & nw_fifo_full_n),
    .full_n(nw_fifo_full_n),
    .din(num_words),
    .read(nw_fifo_read),
    .empty_n(nw_fifo_empty_n),
    .dout(nw_fifo_dout)
);
assign nw_fifo_read = (curr_state_r == SET_COUNTER);

AxiRegSlice #(
    .N(32))   // data width) 
drawWr_data_axi(
    // system signals
    .clk(clk),
    .nReset(nReset),
    // slave side
    .s_data(dramWrData_data),
    .s_valid(dramWrData_valid),
    .s_ready(dramWrData_ready),
    // master side
    .m_data(dramWrData_data_dly1),
    .m_valid(dramWrData_valid_dly1),
    .m_ready(dramWrData_ready_in1 & (curr_state_r == COMPARE))// (~(curr_state_r == PADDING)))
);

assign wdata_en_int = (curr_state_r == PADDING)? 1'b1: (dramWrData_valid_dly1 & (curr_state_r == COMPARE)); // (curr_state_r == COMPARE)? dramWrData_valid_dly1 : (curr_state_r == PADDING);
assign wdata_int = (curr_state_r == PADDING)? 0: dramWrData_data_dly1; //(curr_state_r == COMPARE)? dramWrData_data_dly1: 0;

AxiRegSlice #(
    .N(32))   // data width) 
wdata_axi(
    // system signals
    .clk(clk),
    .nReset(nReset),
    // slave side
    .s_data(wdata_int),
    .s_valid(wdata_en_int),
    .s_ready(dramWrData_ready_in1),
    // master side
    .m_data(wdata),
    .m_valid(wdata_en_int1),
    .m_ready(~wdata_full)
);

assign wdata_en = wdata_en_int1 & (~wdata_full);

always @(posedge clk)
    if (~nReset)
        curr_words_r <= 0;
    else if ((curr_state_r == IDLE) & (curr_words_r[6:0] == 7'b0))
        curr_words_r <= 1;
    else if ((curr_state_r == COMPARE) & (curr_words_r == num_words_r) & (num_words_r[6:0] == 7'b0)) 
        curr_words_r <= 1;
    else if (dramWrData_ready_in1 & dramWrData_valid_dly1 & (curr_state_r == COMPARE))// (curr_state_r != PADDING))
       curr_words_r <= curr_words_r + 1;
    else if ((curr_state_r == PADDING) & (curr_words_r[6:0] == 7'b0))
        curr_words_r <= 1;
    else if ((curr_state_r == PADDING) & dramWrData_ready_in1)
        curr_words_r <= curr_words_r + 1;
        
//main state machine
always @(posedge clk)
    if (~nReset) begin
        curr_state_r <= IDLE;
        num_words_r <= 0;
    end
    else begin
        case (curr_state_r)
            IDLE: if (nw_fifo_empty_n) begin
                    curr_state_r <= SET_COUNTER;
                  end
            SET_COUNTER: begin
                            curr_state_r <= COMPARE;
                            num_words_r <= nw_fifo_dout;
                         end
            COMPARE: if ((curr_words_r == num_words_r) & (num_words_r[6:0] == 7'b0)) begin
                        curr_state_r <= IDLE;
                     end
                     else if (curr_words_r == num_words_r) begin
                        curr_state_r <= PADDING;
                     end
                     else begin
                        curr_state_r <= COMPARE;
                     end
            PADDING: if (curr_words_r[6:0] == 7'b0) begin
                        curr_state_r <= IDLE;
                     end
                     else begin
                        curr_state_r <= PADDING;
                     end
        endcase
     end
        
        //chipscope debuggin
 /*        wire [127:0] data;
          wire [15:0]  trig0;
          wire [35:0] control;
          
            chipscope_icon icon0
               (
                .CONTROL0 (control)
                );
          
             chipscope_ila ila0
               (
                .CLK     (clk),
                .CONTROL (control),
                .TRIG0   (trig0),
                .DATA    (data)
                );
                
             
              assign data[31:0] = wdata;
              assign data[32] = wdata_en;
              assign data[33] = wdata_full;
              
              assign data[65:34] = dramWrData_data;
              assign data[66] = dramWrData_valid;
              assign data[67] = dramWrData_ready;
              assign data[68] = wr_num_words_en;
              assign data[84:69] = num_words;
              assign data[86:85] = curr_state_r;
              assign data[102:87] = curr_words_r;
              
              assign trig0[0] = wdata_en;
              assign trig0[1] = wdata_full;
              assign trig0[2] = wr_num_words_en;
              assign trig0[3] = dramWrData_valid;
              assign trig0[4] = dramWrData_ready;
              assign trig0[6:5] = curr_state_r;*/
endmodule
