`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: Xilinx
// Engineer: Lisa Liu
// 
// Create Date: 03/07/2014 03:32:46 PM
// Design Name: 
// Module Name: mcd_ssd_inf
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: ssd hba interface to be used with memcached value store 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////

module mcd_ssd_inf(
input clk,
input nReset,
input [44:0] cmd_dramRdData_data,
input cmd_dramRdData_valid,
output cmd_dramRdData_ready,
input[44:0] cmd_dramWrData_data,
input cmd_dramWrData_valid,
output cmd_dramWrData_ready,

//ssd side signals
output [2:0] cmd,
output cmd_en,
output [47:0] lba,
output [15:0] sectorcnt,
input cmd_success,
input cmd_failed,
input ncq_idle,
input link_initialized,
//signals to/from mcd
output [31:0] dramRdData_data,
output dramRdData_valid,
input dramRdData_ready,
//signals to/from sata hba
input [31:0] rdata,
input rdata_empty,
output rdata_next,
//signals to / from mcd
input [31:0] dramWrData_data,
input dramWrData_valid,
output dramWrData_ready,
//signal to/from sata hba
output [31:0] wdata,
output wdata_en,
input wdata_full,
output fin_read_sig,

//debug ports
output [1:0] wrConv_curr_state_r_de,
output [15:0] wrConv_curr_words_r_de,
output [1:0] rdConv_curr_state_r_de,
output [15:0] rdConv_curr_words_r_de,
output vio_reset,
output [1:0] rd_state_r_de,
output push_de,
output [15:0] rd_word_r_de,
output has_fault_r_de, 
output start_reading_r_de,
output [15:0] cmd_counter_r_de,
output rd_num_words_en_de
//output cmd_valid_dly1_de, 
//output cmd_valid_dly2_de,
//output cmd_ready_in1_de, 
//output cmd_ready_in2_de
);

wire [45:0] cmd_data;
wire cmd_valid, cmd_ready;

//signals to MemWrDataConv
//since each command can only contain one num_words info for either read or write SSD operation
wire[15:0] num_words; //number of 32-bit words to MemWrDataConv and MemRdDataConv
wire rd_num_words_en; //pulse signal to indicate a new num_words coming
wire wr_num_words_en; //oykse signal to indicate a new num_words coming
reg fin_read_sig_r;

localparam IDLE = 2'd0,
           PUSH = 2'd1,
           FAIL = 2'd2;

reg [15:0] rd_word_r;
reg has_fault_r, start_reading_r;
reg [15:0] cmd_counter_r;

reg [1:0] rd_state_r;
reg push;
wire [31:0] ssd_dramRdData_data;
wire ssd_dramRdData_valid;
wire ssd_dramRdData_ready;
wire [31:0] output_dramRdData_data;
wire output_dramRdData_valid;
wire output_dramRdData_ready;

//debugging signal assignment
assign rd_state_r_de = rd_state_r;
assign push_de = push;
assign rd_word_r_de = rd_word_r;
assign has_fault_r_de = has_fault_r;
assign start_reading_r_de = start_reading_r;
assign cmd_counter_r_de = cmd_counter_r;
assign rd_num_words_en_de = rd_num_words_en;

assign dramRdData_data = (rd_state_r == FAIL)? 32'b0: output_dramRdData_data;
assign output_dramRdData_ready = dramRdData_ready & push;
assign dramRdData_valid = (rd_state_r == FAIL)? 1'b1: (output_dramRdData_valid & push);

always @(posedge clk)
    if (~nReset) begin
        rd_word_r <= 0;
        has_fault_r <= 1'b0;
        start_reading_r <= 1'b0;
    end
    else begin
        if (rd_num_words_en) begin
            start_reading_r <= 1'b1;
            rd_word_r <= num_words;
            if (rd_word_r != 0) begin
                has_fault_r <= 1'b1;
            end
        end
        else if (ssd_dramRdData_valid & ssd_dramRdData_ready) begin
            rd_word_r <= rd_word_r - 1;
            if (rd_word_r == 0) begin
                has_fault_r <= 1'b1;
            end
        end
        else if (rd_word_r == 0) begin
            start_reading_r <= 1'b0;
        end
    end
    

always @(posedge clk)
    if (~nReset) begin
        rd_state_r <= IDLE;
        push <= 1'b0;
    end
    else 
        case (rd_state_r)
            IDLE: begin
                     if (has_fault_r) begin
                        rd_state_r <= FAIL;
                     end
                     else if (start_reading_r & (rd_word_r == 0)) begin
                        rd_state_r <= PUSH;
                        push <= 1'b1;
                     end
                  end
            PUSH: begin
                   if (~output_dramRdData_valid) begin
                        rd_state_r <= IDLE;
                        push <= 1'b0;
                    end
                   end
            FAIL: begin
                    rd_state_r <= FAIL;
                    push <= 1'b0;
                   end
            default: rd_state_r <= IDLE;
        endcase
        
wire [11:0] rdDataFIFO_count;
flashRdData_FIFO flashRdData_FIFO_inst (
  .s_aclk(clk),                // input wire s_aclk
  .s_aresetn(nReset),          // input wire s_aresetn
  .s_axis_tvalid(ssd_dramRdData_valid),  // input wire s_axis_tvalid
  .s_axis_tready(ssd_dramRdData_ready),  // output wire s_axis_tready
  .s_axis_tdata(ssd_dramRdData_data),    // input wire [31 : 0] s_axis_tdata
  .m_axis_tvalid(output_dramRdData_valid),  // output wire m_axis_tvalid
  .m_axis_tready(output_dramRdData_ready),  // input wire m_axis_tready
  .m_axis_tdata(output_dramRdData_data),    // output wire [31 : 0] m_axis_tdata
  .axis_data_count(rdDataFIFO_count)  // output wire [11 : 0] axis_data_count
);

always @(posedge clk)
    fin_read_sig_r <= fin_read_sig;
//aggregate rd and wr cmd stream into one cmd stream
assign cmd_data = (cmd_dramWrData_valid)? {cmd_dramWrData_data, 1'b1}: {cmd_dramRdData_data, 1'b0};
assign cmd_valid = (cmd_dramWrData_valid)? cmd_dramWrData_valid: cmd_dramRdData_valid;
assign cmd_dramWrData_ready = (cmd_dramWrData_valid)? cmd_ready: 1'b0;
assign cmd_dramRdData_ready = (~cmd_dramWrData_valid)? cmd_ready: 1'b0;

McdCmdAdapter McdCmdAdapter_inst(
.clk(clk),
.nReset(nReset),
.cmd_data(cmd_data),
.cmd_valid(cmd_valid),
.cmd_ready(cmd_ready),
.cmd(cmd),
.cmd_en(cmd_en),
.lba(lba),
.sectorcnt(sectorcnt),
.cmd_success(cmd_success),
.cmd_failed(cmd_failed),
.ncq_idle(ncq_idle),
.fin_read_sig(fin_read_sig_r),
.num_words(num_words),
.rd_num_words_en(rd_num_words_en),
.wr_num_words_en(wr_num_words_en)
//.vio_reset(vio_reset)
//.cmd_valid_dly1_de(cmd_valid_dly1_de), 
//.cmd_valid_dly2_de(cmd_valid_dly1_de),
//.cmd_ready_in1_de(cmd_valid_dly1_de), 
//.cmd_ready_in2_de(cmd_valid_dly1_de)
);

rd_data_conv rd_data_conv_inst(
.clk(clk),
.nReset(nReset),
//signals to/from mcd
.dramRdData_data(ssd_dramRdData_data),
.dramRdData_valid(ssd_dramRdData_valid),
.dramRdData_ready(ssd_dramRdData_ready),
//signals to/from sata hba
.rdata(rdata),
.rdata_empty(rdata_empty),
.rdata_next(rdata_next),
.link_initialized(link_initialized),
.fin_read_sig(fin_read_sig),
//signals from McdCmdAdapter indicating how many 32-bit words are expected
.num_words(num_words),
.rd_num_words_en(rd_num_words_en),
.curr_state_r_de(rdConv_curr_state_r_de),
.curr_words_r_de(rdConv_curr_words_r_de)
);

wr_data_conv  wr_data_conv_inst(
.clk(clk),
.nReset(nReset),
//signals to / from mcd
.dramWrData_data(dramWrData_data),
.dramWrData_valid(dramWrData_valid),
.dramWrData_ready(dramWrData_ready),
//signal to/from sata hba
.wdata(wdata),
.wdata_en(wdata_en),
.wdata_full(wdata_full),
//signals from McdCmdAdapter indicating how many 32-bit words are expected
.num_words(num_words),
.wr_num_words_en(wr_num_words_en),
.curr_state_r_de(wrConv_curr_state_r_de),
.curr_words_r_de(wrConv_curr_words_r_de)
);

   always @(posedge clk)
    if (~nReset)
        cmd_counter_r <= 0;
    else if (cmd_en)
        cmd_counter_r <= cmd_counter_r + 1;

//chipscope debuggin
/*reg [255:0] data;
   reg [31:0]  trig0;
   wire [35:0] control0, control1; 
   wire vio_reset;
   

   
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
        data[31:0] <= dramRdData_data;
        data[32] <= dramRdData_valid;
        data[33] <= dramRdData_ready;
        data[65:34] <= rdata;
        data[66] <= rdata_empty;
        data[67] <= rdata_next;
        data[112:68] <= cmd_dramRdData_data;
        data[113] <= cmd_dramRdData_valid;
        data[114] <= cmd_dramRdData_ready;
        data[115] <= cmd_success;
        data[116] <= cmd_failed;
        data[117] <= cmd_en;
        data[120:118] <= cmd;
        data[121] <= rd_num_words_en;
        data[122] <= ssd_dramRdData_valid;
        data[123] <= ssd_dramRdData_ready;
        data[124] <= output_dramRdData_valid;
        data[125] <= output_dramRdData_ready;
        data[126] <= push;
        data[128:127] <= rd_state_r;
        data[129] <= start_reading_r;
        data[130] <= has_fault_r;
        data[162:131] <= rd_word_r;
        data[163] <= fin_read_sig_r;
        data[164] <= link_initialized;
        data[165] <= ncq_idle;
        data[167:166] <= rdConv_curr_state_r_de;
        data[183:168] <= rdConv_curr_words_r_de;
        data[195:184] <= rdDataFIFO_count;
        data[211:196] <= cmd_counter_r;
        
        trig0[0] <= dramRdData_valid;
        trig0[1] <= dramRdData_ready;
        trig0[2] <= rdata_empty;
        trig0[3] <= rdata_next;
        trig0[4] <= cmd_dramRdData_valid;
        trig0[5] <= cmd_dramRdData_ready;
        trig0[6] <= cmd_success;
        trig0[7] <= cmd_failed;
        trig0[8] <= cmd_en;
        trig0[10:9] <= rd_state_r;
        trig0[11] <= has_fault_r;
        trig0[13:12] <= rdConv_curr_state_r_de;
        trig0[14] <= ssd_dramRdData_valid;
        trig0[15] <= ssd_dramRdData_ready;
        trig0[31:16] <= cmd_counter_r;

   end*/
endmodule
