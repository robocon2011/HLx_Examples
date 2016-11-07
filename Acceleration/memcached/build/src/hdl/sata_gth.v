`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 07/10/2014 02:55:04 PM
// Design Name: 
// Module Name: sata_gth
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


module sata_gth(
    input         q6_clk1_gtrefclk_pad_p_in, // GTH reference clock input
    input         q6_clk1_gtrefclk_pad_n_in, // GTH reference clock input
    input         sysclk_in_p, //100MHz differential system clock
    input         sysclk_in_n,
    output sata1_tx_p,
    output sata1_tx_n,
    input sata1_rx_p,
    input sata1_rx_n,
    
    output logic_clk,
    output gth_reset,
    input         hard_reset,     // Active high, reset button pushed on board
    input         soft_reset,     // Active high, user reset can be pulled any time
    //gth outputs
     // RX GTH tile <-> Link Module
    output           RXELECIDLE0,
    output [3:0]     RXCHARISK0,
    output [31:0]    RXDATA,
    output           RXBYTEISALIGNED0,
    output          gt0_rxbyterealign_out,
    output          gt0_rxcommadet_out,
    
     // TX GTH tile <-> Link Module
    input           TXELECIDLE,
    input [31:0]    TXDATA,
    input           TXCHARISK,
          
    output rx_reset_done, 
    output tx_reset_done,
    output rx_comwake_det,
    output rx_cominit_det,
    input tx_cominit, 
    input tx_comwake,
    input rx_start

    );
    
     wire PLLLKDET;     
     wire txusrclk;
     wire sysclk_in_i;
     wire rxoutclk, txoutclk;
     
     reg [31:0] TXDATA_r1, TXDATA_r2, TXDATA_r3;
     reg  TXELECIDLE_r1, TXELECIDLE_r2;
     reg  TXCHARISK_r1, TXCHARISK_r2, TXCHARISK_r3;

     assign gth_reset   =  (soft_reset | hard_reset);
     always @(posedge txusrclk) begin
       TXDATA_r1 <= TXDATA;
       TXDATA_r2 <= TXDATA_r1;
       TXDATA_r3 <= TXDATA_r2;
       TXELECIDLE_r1 <= TXELECIDLE;
       TXELECIDLE_r2 <= TXELECIDLE_r1;
       TXCHARISK_r1 <= TXCHARISK;
       TXCHARISK_r2 <= TXCHARISK_r1;
       TXCHARISK_r3 <= TXCHARISK_r2;
     end
    
     wire gt0_gtrefclk0_in;
     wire sysclk_in;
         
         sata3_gth_ip sata3_gth_inst(
                 .soft_reset_in(soft_reset),
                 .dont_reset_on_data_error_in(1'b0),
                 .q6_clk1_gtrefclk_pad_n_in(q6_clk1_gtrefclk_pad_n_in),
                 .q6_clk1_gtrefclk_pad_p_in(q6_clk1_gtrefclk_pad_p_in),
                 .gt0_tx_fsm_reset_done_out(tx_reset_done),
                 .gt0_rx_fsm_reset_done_out(rx_reset_done),
                 .gt0_data_valid_in(rx_start),
                  
                 .gt0_txusrclk_out(),
                 .gt0_txusrclk2_out(txusrclk),
                 .gt0_rxusrclk_out(),
                 .gt0_rxusrclk2_out(logic_clk),
                  //_________________________________________________________________________
                  //GT0  (X1Y24)
                  //____________________________CHANNEL PORTS________________________________
                  //------------------------------- CPLL Ports -------------------------------
                  .gt0_cpllfbclklost_out          (),
                  .gt0_cplllock_out               (PLLLKDET),
                  .gt0_cpllreset_in               (1'b0),
                  //------------------------ Channel - Clocking Ports ------------------------
                  .gt0_gtrefclk0_in               (1'b0), //not used
                  //------------------- RX Initialization and Reset Ports --------------------
                  .gt0_eyescanreset_in(1'b0),
                  .gt0_rxuserrdy_in(~gth_reset & PLLLKDET),
                  //------------------------ RX Margin Analysis Ports ------------------------
                  .gt0_eyescandataerror_out(),
                  .gt0_eyescantrigger_in(1'b0),
                  //----------------- Receive Ports - Digital Monitor Ports ------------------
                  .gt0_dmonitorout_out(),
                  //---------------- Receive Ports - FPGA RX interface Ports -----------------
                  .gt0_rxdata_out(RXDATA),
                  //---------------- Receive Ports - RX 8B/10B Decoder Ports -----------------
                  .gt0_rxdisperr_out(gt0_rxdisperr_de),
                  .gt0_rxnotintable_out(gt0_rxnotintable_de),
                  //---------------------- Receive Ports - RX AFE Ports ----------------------
                  .gt0_gthrxn_in(sata1_rx_n),
                  //------------ Receive Ports - RX Byte and Word Alignment Ports ------------
                  .gt0_rxbyteisaligned_out(RXBYTEISALIGNED0),
                  .gt0_rxbyterealign_out(gt0_rxbyterealign_out),
                  .gt0_rxcommadet_out(gt0_rxcommadet_out),
                  //------------ Receive Ports - RX Equalizer Ports -------------------
                  .gt0_rxmonitorout_out(),
                  .gt0_rxmonitorsel_in(2'b00),
                  //----------- Receive Ports - RX Initialization and Reset Ports ------------
                  .gt0_gtrxreset_in(gth_reset | ~PLLLKDET),
                  //----------------- Receive Ports - RX OOB Signaling ports -----------------
                  .gt0_rxcomwakedet_out(rx_comwake_det),
                  //---------------- Receive Ports - RX OOB Signaling ports  -----------------
                  .gt0_rxcominitdet_out(rx_cominit_det),
                  //---------------- Receive Ports - RX OOB signalling Ports -----------------
                  .gt0_rxelecidle_out(RXELECIDLE0),
                  //----------------- Receive Ports - RX8B/10B Decoder Ports -----------------
                  .gt0_rxcharisk_out(RXCHARISK0),
                  //---------------------- Receive Ports -RX AFE Ports -----------------------
                  .gt0_gthrxp_in(sata1_rx_p),
                  //------------ Receive Ports -RX Initialization and Reset Ports ------------
                  .gt0_rxresetdone_out(),
                  //------------------- TX Initialization and Reset Ports --------------------
                  .gt0_gttxreset_in(gth_reset | ~PLLLKDET),
                  .gt0_txuserrdy_in(~gth_reset & PLLLKDET),
                  //------------------- Transmit Ports - PCI Express Ports -------------------
                  .gt0_txelecidle_in(TXELECIDLE_r2),
                  //---------------- Transmit Ports - TX Data Path interface -----------------
                  .gt0_txdata_in(TXDATA_r3),
                  //-------------- Transmit Ports - TX Driver and OOB signaling --------------
                  .gt0_gthtxn_out(sata1_tx_n),
                  .gt0_gthtxp_out(sata1_tx_p),
                  //--------- Transmit Ports - TX Fabric Clock Output Control Ports ----------
                  .gt0_txoutclkfabric_out(),
                  .gt0_txoutclkpcs_out(),
                  //----------- Transmit Ports - TX Initialization and Reset Ports -----------
                  .gt0_txresetdone_out(),
                  //---------------- Transmit Ports - TX OOB signalling Ports ----------------
                  .gt0_txcominit_in(tx_cominit),
                  .gt0_txcomwake_in(tx_comwake),
                  //--------- Transmit Transmit Ports - 8b10b Encoder Control Ports ----------
                  .gt0_txcharisk_in({3'b0, TXCHARISK_r3}),
                 
                  //____________________________COMMON PORTS________________________________
                  //.gt0_qplllock_out(),
                  //.gt0_qpllrefclklost_out(),
                 // .gt0_qpllreset_out(),
                  .gt0_qplloutclk_out(),
                  .gt0_qplloutrefclk_out(),
                  .DRP_CLK_O(), //output clock for DRP ports
                  .sysclk_in_p(sysclk_in_p),
                  .sysclk_in_n(sysclk_in_n)
                  //.rxreset_de(rxreset_de),
                  //.txreset_de(txreset_de)
                 );
                
endmodule
