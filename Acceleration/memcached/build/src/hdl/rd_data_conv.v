`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: Xilinx
// Engineer: Lisa Liu
// 
// Create Date: 03/11/2014 10:59:20 AM
// Design Name: 
// Module Name: rd_data_conv
// Project Name: 
// Target Devices: VC709
// Tool Versions: 
// Description: convert SATA HBA read data path to mcd read data path
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module rd_data_conv(
input clk,
input nReset,
//signals to/from mcd
output [31:0] dramRdData_data,
output dramRdData_valid,
input dramRdData_ready,
//signals to/from sata hba
input [31:0] rdata,
input rdata_empty,
output rdata_next,
input link_initialized,
output fin_read_sig,
//signals from McdCmdAdapter indicating how many 32-bit words are expected
input [15:0] num_words,
input rd_num_words_en,
//debug ports
output[1:0] curr_state_r_de,
output [15:0] curr_words_r_de
    );

localparam IDLE = 2'd0;
localparam SET_COUNTER = 2'd1;
localparam COMPARE = 2'd2;
localparam TRUNCATE = 2'd3;

reg [3:0] sig_counter_r;
reg read_sig_r;

reg [1:0] curr_state_r;
reg [15:0] num_words_r, curr_words_r;
reg fin_read_sig_r;

wire nw_fifo_full_n;
wire nw_fifo_empty_n;
wire nw_fifo_read;
wire[15:0] nw_fifo_dout;

wire rdata_next_int;

wire [31:0] rdata_dly1;
wire rdata_valid_dly1;
wire rdata_ready_in1, rdata_ready_in2;
wire [31:0] dramRdData_data_int;
wire dramRdData_valid_int;

reg rdata_ready_in1_r;

//debug logic
assign curr_state_r_de = curr_state_r;
assign curr_words_r_de = curr_words_r;

assign fin_read_sig = fin_read_sig_r;
assign rdata_next = (rdata_next_int & ~rdata_empty) | ((sig_counter_r !=5) & ~rdata_empty);

//store num_words into fifo
reg_fifo #(
    .DATA_BITS(16),
    .DEPTH_BITS(4))
reg_fifo_inst(
    .clk(clk),
    .nReset(nReset),
    .write(rd_num_words_en & nw_fifo_full_n),
    .full_n(nw_fifo_full_n),
    .din(num_words),
    .read(nw_fifo_read),
    .empty_n(nw_fifo_empty_n),
    .dout(nw_fifo_dout)
);
assign nw_fifo_read = (curr_state_r == SET_COUNTER);

AxiRegSlice #(
    .N(32))   // data width) 
rdata_axi(
    // system signals
    .clk(clk),
    .nReset(nReset),
    // slave side
    .s_data(rdata),
    .s_valid(~rdata_empty & (sig_counter_r==5)),
    .s_ready(rdata_next_int),
    // master side
    .m_data(rdata_dly1),
    .m_valid(rdata_valid_dly1),
    .m_ready(rdata_ready_in1)
);

assign dramRdData_valid_int = (curr_state_r == COMPARE)? (rdata_valid_dly1 & (curr_words_r != num_words_r)) : 1'b0;
assign dramRdData_data_int = (curr_state_r == COMPARE)? rdata_dly1: 0;
assign rdata_ready_in1 =rdata_ready_in2; // (curr_state_r == COMPARE)? rdata_ready_in2: // & rdata_ready_in1_r: 
                        // (curr_state_r == TRUNCATE)? 1'b1: //rdata_ready_in1_r: 
                        // 1'b0;

AxiRegSlice #(
    .N(32))   // data width) 
dramRdData_axi(
    // system signals
    .clk(clk),
    .nReset(nReset),
    // slave side
    .s_data(dramRdData_data_int),
    .s_valid(dramRdData_valid_int),
    .s_ready(rdata_ready_in2),
    // master side
    .m_data(dramRdData_data),
    .m_valid(dramRdData_valid),
    .m_ready(dramRdData_ready)
);

always @(posedge clk)
    if (~nReset)
        rdata_ready_in1_r <= 1'b0;
    else if (curr_state_r == SET_COUNTER)
        rdata_ready_in1_r <= 1'b1;
    else if (curr_words_r ==  (num_words_r - 1))
        rdata_ready_in1_r <= 1'b0;

always @(posedge clk) 
    if (~link_initialized) begin
        sig_counter_r <= 0;
        read_sig_r <= 1'b0;
        fin_read_sig_r <= 1'b0;
    end
    else if (~rdata_empty & (sig_counter_r != 5))begin
        sig_counter_r <= sig_counter_r+1;
        read_sig_r <= 1'b1;
        fin_read_sig_r <= fin_read_sig_r;
    end
    else if (sig_counter_r == 5) begin
        fin_read_sig_r <= 1'b1;
        sig_counter_r <= sig_counter_r;
        read_sig_r <= 1'b0;
    end
//main state machine
always @(posedge clk)
    if (~nReset) begin
        curr_state_r <= IDLE;
        curr_words_r <= 0;
        num_words_r <= 0;
    end
    else
        case (curr_state_r)
            IDLE: if (nw_fifo_empty_n) begin
                    curr_state_r <= SET_COUNTER;
                    curr_words_r <= 0;
                  end
            SET_COUNTER: begin
                            curr_state_r <= COMPARE;
                            curr_words_r <= 0;
                            num_words_r <= nw_fifo_dout;
                         end
            COMPARE: 
                    if ((curr_words_r == num_words_r) & (num_words_r[6:0] == 7'b0)) begin
                         curr_state_r <= IDLE;
                         curr_words_r <= 0;
                     end 
                    else if (curr_words_r == num_words_r) begin
                        curr_state_r <= TRUNCATE;
                        curr_words_r <= curr_words_r+1;
                     end
                     else if (rdata_ready_in2 & rdata_valid_dly1) begin
                        curr_words_r <= curr_words_r + 1;
                        curr_state_r <= COMPARE;
                     end
                     else begin
                        curr_words_r <= curr_words_r;
                        curr_state_r <= COMPARE;
                     end
            TRUNCATE: if (curr_words_r[6:0] == 7'b0000000) begin
                        curr_state_r <= IDLE;
                        curr_words_r <= 0;
                     end
                     else begin
                        if (rdata_ready_in1 & rdata_valid_dly1) begin
                            curr_words_r <= curr_words_r + 1;
                        end
                        else begin
                            curr_words_r <= curr_words_r;
                        end
                        curr_state_r <= TRUNCATE;
                     end
        endcase
        
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
              
           
            assign data[31:0] = rdata;
            assign data[32] = rdata_empty;
            assign data[33] = rdata_next;
            
            assign data[65:34] = rdata_dly1;
            assign data[66] = dramRdData_valid;
            assign data[67] = dramRdData_ready;
            assign data[68] = read_sig_r;
            assign data[69] = fin_read_sig;
            assign data[71:70] = curr_state_r;
            assign data[87:72] = num_words_r;
            assign data[103:88] = curr_words_r;
            assign data[104] = rdata_ready_in1;
            assign data[105] = rdata_valid_dly1;
            
            assign trig0[0] = rdata_empty;
            assign trig0[1] = rdata_next;
            assign trig0[2] = dramRdData_valid;
            assign trig0[3] = dramRdData_ready;*/
           
endmodule
