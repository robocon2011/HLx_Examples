`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 03/12/2014 10:10:27 AM
// Design Name: 
// Module Name: mcd_mem_node_ssd
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


module ssd_mem_node(
input clk156,
input nReset156,
//signals to/from sata GTH
input clk150,
        input gth_reset,
        output         hard_reset,     // Active high, reset button pushed on board
        output         soft_reset,     // Active high, user reset can be pulled any time
        //gth outputs
         // RX GTH tile <-> Link Module
        input           RXELECIDLE0,
        input [3:0]     RXCHARISK0,
        input [31:0]    RXDATA,
        input           RXBYTEISALIGNED0,
        input          gt0_rxbyterealign_out,
        input          gt0_rxcommadet_out,
        
         // TX GTH tile <-> Link Module
        output           TXELECIDLE,
        output [31:0]    TXDATA,
        output           TXCHARISK,
              
        input rx_reset_done, 
        input tx_reset_done,
        input rx_comwake_det,
        input rx_cominit_det,
        output tx_cominit, 
        output tx_comwake,
        output rx_start,
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

output link_initialized_clk156,
output ncq_idle_clk156,
output fin_read_sig_clk156,

//debug signal
output vio_reset_156 //active high reset from vio core
);

wire nReset150;
//clk150 signals
wire [44:0] clk150_cmd_dramRdData_data;
wire clk150_cmd_dramRdData_valid;
wire clk150_cmd_dramRdData_ready;
wire [44:0] clk150_cmd_dramWrData_data;
wire clk150_cmd_dramWrData_valid;
wire clk150_cmd_dramWrData_ready;
wire [31:0] clk150_dramRdData_data;
wire clk150_dramRdData_valid;
wire clk150_dramRdData_ready;
wire [31:0] clk150_dramWrData_data;
wire clk150_dramWrData_valid;
wire clk150_dramWrData_ready;

mcd2ssd_clock_cross mcd2ssd_clock_cross_inst(
.clk156(clk156),
.clk150(clk150),
.nReset156(nReset156),
.nReset150(nReset150),
//clk156 signals
.clk156_cmd_dramRdData_data(clk156_cmd_dramRdData_data),
.clk156_cmd_dramRdData_valid(clk156_cmd_dramRdData_valid),
.clk156_cmd_dramRdData_ready(clk156_cmd_dramRdData_ready),
.clk156_cmd_dramWrData_data(clk156_cmd_dramWrData_data),
.clk156_cmd_dramWrData_valid(clk156_cmd_dramWrData_valid),
.clk156_cmd_dramWrData_ready(clk156_cmd_dramWrData_ready),
.clk156_dramRdData_data(clk156_dramRdData_data),
.clk156_dramRdData_valid(clk156_dramRdData_valid),
.clk156_dramRdData_ready(clk156_dramRdData_ready),
.clk156_dramWrData_data(clk156_dramWrData_data),
.clk156_dramWrData_valid(clk156_dramWrData_valid),
.clk156_dramWrData_ready(clk156_dramWrData_ready),

//clk150 signals
.clk150_cmd_dramRdData_data(clk150_cmd_dramRdData_data),
.clk150_cmd_dramRdData_valid(clk150_cmd_dramRdData_valid),
.clk150_cmd_dramRdData_ready(clk150_cmd_dramRdData_ready),
.clk150_cmd_dramWrData_data(clk150_cmd_dramWrData_data),
.clk150_cmd_dramWrData_valid(clk150_cmd_dramWrData_valid),
.clk150_cmd_dramWrData_ready(clk150_cmd_dramWrData_ready),
.clk150_dramRdData_data(clk150_dramRdData_data),
.clk150_dramRdData_valid(clk150_dramRdData_valid),
.clk150_dramRdData_ready(clk150_dramRdData_ready),
.clk150_dramWrData_data(clk150_dramWrData_data),
.clk150_dramWrData_valid(clk150_dramWrData_valid),
.clk150_dramWrData_ready(clk150_dramWrData_ready)
);

//ssd side signals
wire [2:0] cmd;
wire cmd_en;
wire [47:0] lba;
wire [15:0] sectorcnt;
wire cmd_success;
wire cmd_failed;
wire ncq_idle;
wire link_initialized;
//signals to/from sata hba
wire [31:0] rdata;
wire rdata_empty;
wire rdata_next;
//signal to/from sata hba
wire [31:0] wdata;
wire wdata_en;
wire wdata_full;
wire fin_read_sig;

//debugging signals
wire [1:0] wrConv_curr_state_r_de;
wire [15:0] wrConv_curr_words_r_de;
wire [1:0] rdConv_curr_state_r_de;
wire [15:0] rdConv_curr_words_r_de;
wire cmd_valid_dly1_de; 
wire cmd_valid_dly2_de;
wire cmd_ready_in1_de; 
wire cmd_ready_in2_de;
wire [1:0] rd_state_r_de;
wire push_de;
wire [15:0] rd_word_r_de;
wire has_fault_r_de; 
wire start_reading_r_de;
wire [15:0] cmd_counter_r_de;
wire rd_num_words_en_de;

//debug signals
wire vio_reset; //active high reset from vio

mcd_ssd_inf mcd_ssd_inf_inst(
.clk(clk150),
.nReset(nReset150),
.cmd_dramRdData_data(clk150_cmd_dramRdData_data),
.cmd_dramRdData_valid(clk150_cmd_dramRdData_valid),
.cmd_dramRdData_ready(clk150_cmd_dramRdData_ready),
.cmd_dramWrData_data(clk150_cmd_dramWrData_data),
.cmd_dramWrData_valid(clk150_cmd_dramWrData_valid),
.cmd_dramWrData_ready(clk150_cmd_dramWrData_ready),

//ssd side signals
.cmd(cmd),
.cmd_en(cmd_en),
.lba(lba),
.sectorcnt(sectorcnt),
.cmd_success(cmd_success),
.cmd_failed(cmd_failed),
.ncq_idle(ncq_idle),
.link_initialized(link_initialized),
//signals to/from mcd
.dramRdData_data(clk150_dramRdData_data),
.dramRdData_valid(clk150_dramRdData_valid),
.dramRdData_ready(clk150_dramRdData_ready),
//signals to/from sata hba
.rdata(rdata),
.rdata_empty(rdata_empty),
.rdata_next(rdata_next),
//signals to / from mcd
.dramWrData_data(clk150_dramWrData_data),
.dramWrData_valid(clk150_dramWrData_valid),
.dramWrData_ready(clk150_dramWrData_ready),
//signal to/from sata hba
.wdata(wdata),
.wdata_en(wdata_en),
.wdata_full(wdata_full),
.fin_read_sig(fin_read_sig),
//debugging wires
.wrConv_curr_state_r_de(wrConv_curr_state_r_de),
.wrConv_curr_words_r_de(wrConv_curr_words_r_de),
.rdConv_curr_state_r_de(rdConv_curr_state_r_de),
.rdConv_curr_words_r_de(rdConv_curr_words_r_de),
.vio_reset(),
.rd_state_r_de(rd_state_r_de),
.push_de(push_de),
.rd_word_r_de(rd_word_r_de),
.has_fault_r_de(has_fault_r_de), 
.start_reading_r_de(start_reading_r_de),
.cmd_counter_r_de(cmd_counter_r_de),
.rd_num_words_en_de(rd_num_words_en_de)
);

reg nReset150_r, soft_reset_r;
reg soft_reset_en_r, soft_reset_en_r1;
reg link_initialized_clk156_r1, link_initialized_clk156_r2;
reg ncq_idle_clk156_r1, ncq_idle_clk156_r2;
reg fin_read_sig_clk156_r1, fin_read_sig_clk156_r2;

assign link_initialized_clk156 = link_initialized_clk156_r2;
assign ncq_idle_clk156 = ncq_idle_clk156_r2;
assign fin_read_sig_clk156 = fin_read_sig_clk156_r2;

/**
reset logic. nReset150_soft_r should be asserted for one clk150 cycle after nReset150 goes up
*/
//generate link_initialized sigal in 156.25MHz clock domain
always @(posedge clk156) begin
    link_initialized_clk156_r1 <= link_initialized;
    link_initialized_clk156_r2 <= link_initialized_clk156_r1;
    ncq_idle_clk156_r1 <= ncq_idle;
    ncq_idle_clk156_r2 <= ncq_idle_clk156_r1;
    fin_read_sig_clk156_r1 <= fin_read_sig;
    fin_read_sig_clk156_r2 <= fin_read_sig_clk156_r1;
end

assign nReset150 = nReset150_r;

always @(posedge clk150)
    if (~nReset156)
        nReset150_r <= 1'b0;
    else if (link_initialized)
        nReset150_r <= 1'b1;
        
always @(posedge clk150)
    if (~nReset150) begin
        soft_reset_en_r <= 1'b0;
        soft_reset_en_r1 <= 1'b0;
    end
    else begin
        soft_reset_en_r <= 1'b1;
        soft_reset_en_r1 <= soft_reset_en_r;
    end

always @(posedge clk150)
     soft_reset_r <= soft_reset_en_r & ~soft_reset_en_r1;

//debug signals
wire [6:0]   tran_state_de;
wire [5:0]   link_state_de;
wire         to_link_FIS_rdy_de;
wire         to_link_done_de;
wire         to_link_receive_empty_de;
wire         to_link_receive_overflow_de;
wire         to_link_send_empty_de;
wire         to_link_send_underrun_de;
    
wire    from_link_idle_de;
wire    from_link_ready_to_transmit_de;
wire    from_link_next_de;
wire    from_link_data_en_de;
wire    from_link_done_de;
wire    from_link_err_de;
    
wire [31:0] link_tx_data_de, tx_data_r0_de;
wire [31:0] link_rx_data_de;
wire [3:0] rx_charisk_de;
wire [4:0] current_sectorcnt_de;
wire wordcnt_en_de;
wire wordcnt_clear_de;
wire [7:0]  wordcnt_de;
wire [31:0] from_link_data_de;
wire [31:0] to_link_data_de;
wire tx_charisk_de;


assign hard_reset = ~nReset156;
assign soft_reset =soft_reset_r;
           	 
hba_no_gth hba_inst(
    // HBA main interface: input ports
    .cmd(cmd),
    .cmd_en(cmd_en),
    .lba(lba),
    .sectorcnt(sectorcnt),
    .wdata(wdata),
    .wdata_en(wdata_en),
    .rdata_next(rdata_next), 

    // HBA main interface: output ports
    .wdata_full(wdata_full),
    .rdata(rdata),
    .rdata_empty(rdata_empty),
    .cmd_failed(cmd_failed),
    .cmd_success(cmd_success),

    // HBA additional reporting signals
    .link_initialized(link_initialized),
   
   //connections to GTH
     .logic_clk(clk150),
     .gth_reset(gth_reset),
     
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

    // HBA NCQ extension
    .ncq_wtag(5'd0),
    .ncq_rtag(),
    .ncq_idle(ncq_idle),
    .ncq_relinquish(),
    .ncq_ready_for_wdata(),
    .ncq_SActive(),
    .ncq_SActive_valid(),
    
        //debug ports
                         .tran_state_de(tran_state_de),
                         .link_state_de(link_state_de),
                         .to_link_FIS_rdy_de(to_link_FIS_rdy_de),
                         .to_link_done_de(to_link_done_de),
                         .to_link_receive_empty_de(to_link_receive_empty_de),
                         .to_link_receive_overflow_de(to_link_receive_overflow_de),
                         .to_link_send_empty_de(to_link_send_empty_de),
                         .to_link_send_underrun_de(to_link_send_underrun_de),
                             
                         .from_link_idle_de(from_link_idle_de),
                         .from_link_ready_to_transmit_de(from_link_ready_to_transmit_de),
                         .from_link_next_de(from_link_next_de),
                         .from_link_data_en_de(from_link_data_en_de),
                         .from_link_done_de(from_link_done_de),
                         .from_link_err_de(from_link_err_de),
                             
                         .link_tx_data_de(link_tx_data_de),
                         .link_rx_data_de(link_rx_data_de),
                         .rx_charisk_de(rx_charisk_de),
                         .current_sectorcnt_de(current_sectorcnt_de),
                         .wordcnt_en_de(wordcnt_en_de),
                         .wordcnt_clear_de(wordcnt_clear_de),
                         .wordcnt_de(wordcnt_de),
                         .from_link_data_de(from_link_data_de),
                         .to_link_data_de(to_link_data_de),
                         .tx_charisk_de(tx_charisk_de),
                         .tx_data_r0_de(tx_data_r0_de)
);

/* ------------------------------------------------------------ */
/* ChipScope Debugging                                          */
/* ------------------------------------------------------------ */
//chipscope debugging
reg [255:0] data;
reg [31:0]  trig0;
wire [35:0] control0, control1;
reg vio_reset_156_r;
reg start_hangup_r;

assign vio_reset_156 = vio_reset_156_r;

always @(posedge clk156)
    vio_reset_156_r <= vio_reset;
    
chipscope_icon icon0
(
    .CONTROL0 (control0),
    .CONTROL1 (control1)
);

chipscope_ila ila0
(
    .CLK     (clk150),
    .CONTROL (control0),
    .TRIG0   (trig0),
    .DATA    (data)
);
chipscope_vio vio0
(
    .CONTROL(control1),
    .ASYNC_OUT(vio_reset)
);

/*always @(posedge clk156) begin
    data[44:0] <= clk156_cmd_dramRdData_data;
    data[45] <= clk156_cmd_dramRdData_valid;
    data[46] <= clk156_cmd_dramRdData_ready;
    
    data[91:47] <= clk156_cmd_dramWrData_data;
    data[92] <= clk156_cmd_dramWrData_valid;
    data[93] <= clk156_cmd_dramWrData_ready;
    
    data[157:94] <= clk156_dramRdData_data;
    data[158] <=  clk156_dramRdData_valid;
    data[159] <= clk156_dramRdData_ready;
    
    data [223:160] <= clk156_dramWrData_data;
    data[224] <= clk156_dramWrData_valid;
    data[225] <= clk156_dramWrData_ready;
    data[226] <= link_initialized_clk156;
    data[227] <= ncq_idle_clk156;
    data[228] <= fin_read_sig_clk156;
    
    trig0[0] <= clk156_cmd_dramRdData_valid;
    trig0[1] <= clk156_cmd_dramRdData_ready;
    trig0[2] <= clk156_cmd_dramWrData_valid;
    trig0[3] <= clk156_cmd_dramWrData_ready;
    trig0[4] <= clk156_dramRdData_valid;
    trig0[5] <= clk156_dramRdData_ready;
    trig0[6] <= clk156_dramWrData_valid;
    trig0[7] <= clk156_dramWrData_ready;
end*/

always @(posedge clk150)
    if (~nReset150)
        start_hangup_r <= 1'b0;
    else if ((tran_state_de == 7'h17) & (link_state_de == 6'h0a) & (to_link_send_empty_de) & (~from_link_done_de))
        start_hangup_r <= 1'b1;
        
always @(posedge clk150) begin
     //debug ports
 data[6:0] <=   tran_state_de;
 data[12:7] <=  link_state_de;

 data[47:16] <= link_rx_data_de;
 data[79:48] <= from_link_data_de;

 //data[127:80] <= lba[47:0];
 /*data[81:80] <= wrConv_curr_state_r_de;
 data[97:82] <= wrConv_curr_words_r_de;
 data[99:98] <= rdConv_curr_state_r_de;
 data[115:100] <= rdConv_curr_words_r_de;*/
 data[124:80] <= clk150_cmd_dramWrData_data;
 data[125] <= clk150_cmd_dramWrData_valid;
 data[126] <=clk150_cmd_dramWrData_ready;
  
 data[175:144] <= tx_data_r0_de;
 
 data[177:176] <= rd_state_r_de;
 data[178] <= push_de;
 data[179] <= has_fault_r_de; 
 data[180] <= start_reading_r_de;
 data[196:181] <= cmd_counter_r_de;
 data[212:197] <= rd_word_r_de; 
 
 data[213] <= clk150_cmd_dramRdData_valid;
 data[214] <= clk150_cmd_dramRdData_ready;
 data[215] <= clk150_dramRdData_valid;
 data[216] <= clk150_dramRdData_ready;
                           
 data[217] <= fin_read_sig;
 data[218] <= link_initialized;
 data[221:219] <= cmd;
 data[222] <= cmd_en;

 data[223] <= cmd_success;
 data[224] <= cmd_failed;

 data[225] <= from_link_done_de;
 data[226] <= from_link_err_de;
 
 data[227] <= rx_charisk_de;
 data[228] <= from_link_data_en_de;
 data[229] <= tx_charisk_de;
 data[230] <= from_link_next_de;
 data[231] <= to_link_send_empty_de;
 data[232] <=    to_link_done_de;
 data[233] <= rd_num_words_en_de;
 data[234] <= start_hangup_r;


 trig0[6:0] <=   tran_state_de;
 trig0[12:7] <=  link_state_de;
 trig0[13] <= cmd_en; //rxReAlign_de;
 trig0[14] <= has_fault_r_de;
 trig0[15] <= cmd_failed; 
 trig0[16] <= to_link_send_empty_de;
 trig0[17] <= from_link_err_de;
 trig0[18] <= clk150_dramRdData_valid;
 trig0[19] <= start_hangup_r;
 //trig0[31:20] <= rd_word_r_de[11:0];
 trig0[20] <= clk150_cmd_dramRdData_valid;
 trig0[21] <= clk150_cmd_dramRdData_ready;
 trig0[22] <= clk150_cmd_dramWrData_valid;
 trig0[23] <= clk150_cmd_dramWrData_ready;
 trig0[24] <= clk150_dramRdData_valid;
 trig0[25] <= clk150_dramRdData_ready;
 trig0[26] <= clk150_dramWrData_valid;
 trig0[27] <= clk150_dramWrData_ready;
end

endmodule
