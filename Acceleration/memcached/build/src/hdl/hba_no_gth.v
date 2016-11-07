//Microsoft Research License Agreement
//Non-Commercial Use Only
// SATA core
//_____________________________________________________________________
//
//This Microsoft Research License Agreement, including all exhibits ("MSR-LA") is a legal agreement between you and Microsoft Corporation (?Microsoft? or ?we?) for the software or data identified above, which may include source code, and any associated materials, text or speech files, associated media and "online" or electronic documentation and any updates we provide in our discretion (together, the "Software"). 
//
//By installing, copying, or otherwise using this Software, found at http://research.microsoft.com/downloads, you agree to be bound by the terms of this MSR-LA.  If you do not agree, do not install copy or use the Software. The Software is protected by copyright and other intellectual property laws and is licensed, not sold.    
//
//SCOPE OF RIGHTS:
//You may use, copy, reproduce, and distribute this Software for any non-commercial purpose, subject to the restrictions in this MSR-LA. Some purposes which can be non-commercial are teaching, academic research, public demonstrations and personal experimentation. You may also distribute this Software with books or other teaching materials, or publish the Software on websites, that are intended to teach the use of the Software for academic or other non-commercial purposes.
//You may not use or distribute this Software or any derivative works in any form for commercial purposes. Examples of commercial purposes would be running business operations, licensing, leasing, or selling the Software, distributing the Software for use with commercial products, using the Software in the creation or use of commercial products or any other activity which purpose is to procure a commercial gain to you or others.
//If the Software includes source code or data, you may create derivative works of such portions of the Software and distribute the modified Software for non-commercial purposes, as provided herein.  
//If you distribute the Software or any derivative works of the Software, you will distribute them under the same terms and conditions as in this license, and you will not grant other rights to the Software or derivative works that are different from those provided by this MSR-LA. 
//If you have created derivative works of the Software, and distribute such derivative works, you will cause the modified files to carry prominent notices so that recipients know that they are not receiving the original Software. Such notices must state: (i) that you have changed the Software; and (ii) the date of any changes.
//
//In return, we simply require that you agree: 
//1. That you will not remove any copyright or other notices from the Software.
//2. That if any of the Software is in binary format, you will not attempt to modify such portions of the Software, or to reverse engineer or decompile them, except and only to the extent authorized by applicable law. 
//3. That Microsoft is granted back, without any restrictions or limitations, a non-exclusive, perpetual, irrevocable, royalty-free, assignable and sub-licensable license, to reproduce, publicly perform or display, install, use, modify, post, distribute, make and have made, sell and transfer your modifications to and/or derivative works of the Software source code or data, for any purpose.  
//4. That any feedback about the Software provided by you to us is voluntarily given, and Microsoft shall be free to use the feedback as it sees fit without obligation or restriction of any kind, even if the feedback is designated by you as confidential. 
//5.  THAT THE SOFTWARE COMES "AS IS", WITH NO WARRANTIES. THIS MEANS NO EXPRESS, IMPLIED OR STATUTORY WARRANTY, INCLUDING WITHOUT LIMITATION, WARRANTIES OF MERCHANTABILITY OR FITNESS FOR A PARTICULAR PURPOSE, ANY WARRANTY AGAINST INTERFERENCE WITH YOUR ENJOYMENT OF THE SOFTWARE OR ANY WARRANTY OF TITLE OR NON-INFRINGEMENT. THERE IS NO WARRANTY THAT THIS SOFTWARE WILL FULFILL ANY OF YOUR PARTICULAR PURPOSES OR NEEDS. ALSO, YOU MUST PASS THIS DISCLAIMER ON WHENEVER YOU DISTRIBUTE THE SOFTWARE OR DERIVATIVE WORKS.
//6.  THAT NEITHER MICROSOFT NOR ANY CONTRIBUTOR TO THE SOFTWARE WILL BE LIABLE FOR ANY DAMAGES RELATED TO THE SOFTWARE OR THIS MSR-LA, INCLUDING DIRECT, INDIRECT, SPECIAL, CONSEQUENTIAL OR INCIDENTAL DAMAGES, TO THE MAXIMUM EXTENT THE LAW PERMITS, NO MATTER WHAT LEGAL THEORY IT IS BASED ON. ALSO, YOU MUST PASS THIS LIMITATION OF LIABILITY ON WHENEVER YOU DISTRIBUTE THE SOFTWARE OR DERIVATIVE WORKS.
//7.  That we have no duty of reasonable care or lack of negligence, and we are not obligated to (and will not) provide technical support for the Software.
//8.  That if you breach this MSR-LA or if you sue anyone over patents that you think may apply to or read on the Software or anyone's use of the Software, this MSR-LA (and your license and rights obtained herein) terminate automatically.  Upon any such termination, you shall destroy all of your copies of the Software immediately.  Sections 3, 4, 5, 6, 7, 8, 11 and 12 of this MSR-LA shall survive any termination of this MSR-LA.
//9.  That the patent rights, if any, granted to you in this MSR-LA only apply to the Software, not to any derivative works you make.
//10. That the Software may be subject to U.S. export jurisdiction at the time it is licensed to you, and it may be subject to additional export or import laws in other places.  You agree to comply with all such laws and regulations that may apply to the Software after delivery of the software to you.
//11. That all rights not expressly granted to you in this MSR-LA are reserved.
//12. That this MSR-LA shall be construed and controlled by the laws of the State of Washington, USA, without regard to conflicts of law.  If any provision of this MSR-LA shall be deemed unenforceable or contrary to law, the rest of this MSR-LA shall remain in full effect and interpreted in an enforceable manner that most nearly captures the intent of the original language. 
//----------------------------------------------------------------------------

/* ---------------------------------------------------------------------------
 * Project       : Groundhog : A Serial ATA Host Bus Adapter (HBA) for FPGAs
 * Author        : Louis Woods <louis.woods@inf.ethz.ch>, ported to VC709 by Lisa Liu
 * Module        : HBA
 * Created       : April 18 2012
 * Last Update   : April 25 2012
 * Last Update   : July 29 2013
 * ---------------------------------------------------------------------------
 * Description   : This module provides the interface of the SATA core to 
 *                 any FPGA application. It instantiates the speed control 
 *                 module, the DCM, the link module and the transport module.
 * ------------------------------------------------------------------------- */
 
module hba_no_gth
   (
    // HBA main interface: input ports
    input [2:0]   cmd,
    input         cmd_en,
    input [47:0]  lba,
    input [15:0]  sectorcnt,
    input [31:0]  wdata,
    input         wdata_en,
    input         rdata_next, 

    // HBA main interface: output ports
    output        wdata_full,
    output [31:0] rdata,
    output        rdata_empty,
    output        cmd_failed,
    output        cmd_success,

    // HBA additional reporting signals
    output        link_initialized,
    //output [1:0]  link_gen,

    // HBA NCQ extension
    input [4:0]   ncq_wtag,
    output [4:0]  ncq_rtag,
    output        ncq_idle,
    output        ncq_relinquish,
    output        ncq_ready_for_wdata,
    output [31:0] ncq_SActive,
    output        ncq_SActive_valid,
    
    input logic_clk,
    input gth_reset,
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
    output tx_reset,
    
        //debug ports
        output [6:0]   tran_state_de,
        output [5:0]   link_state_de,
        output         to_link_FIS_rdy_de,
        output         to_link_done_de,
        output         to_link_receive_empty_de,
        output         to_link_receive_overflow_de,
        output         to_link_send_empty_de,
        output         to_link_send_underrun_de,
        
        output    from_link_idle_de,
        output    from_link_ready_to_transmit_de,
        output    from_link_next_de,
        output    from_link_data_en_de,
        output    from_link_done_de,
        output    from_link_err_de,
        
        output [31:0] link_tx_data_de,
        output [31:0] link_rx_data_de,
        output [3:0] rx_charisk_de,
        
        output [4:0]         current_sectorcnt_de,
        output wordcnt_en_de,
        output wordcnt_clear_de,
        output [7:0]         wordcnt_de,
        output [31:0] from_link_data_de,
        output [31:0] to_link_data_de,
        output tx_charisk_de,
        output [31:0] rx_scramblerMask_de,
        output [31:0] tx_scramblerMask_de,
        output [31:0] tx_data_r0_de,
        output prim_hold_det_de,
        output crcReset_de,
        output crcEn_de,
        output [31:0] crcCode_de,
        output scramblerReset_de,
        output scramblerEn_de,
        output scramblerNoPause_de,
        output[2:0] align_countdown_de,
        //output  [3:0]   gt0_rxdisperr_de,
        //output  [3:0]   gt0_rxnotintable_de,
        output rxByteIsAligned_de,
        output rxElecIdle_de,
        //output rxReAlign_de,
        //output rxCommaDet_de,
        //output tx_reset_done_de,
        //output rx_reset_done_de,
        output rx_start_de,
        output prim_r_err_det_de
    );

	wire drp_clk;
   // Link module connections
   wire           from_link_comreset;
   wire           from_link_initialized;
   wire           from_link_idle;
   wire           from_link_ready_to_transmit;
   wire           from_link_next;
   wire [31:0]    from_link_data;
   wire           from_link_data_en;
   wire           from_link_done;
   wire           from_link_err;

   wire           to_link_FIS_rdy;
   wire [31:0]    to_link_data;
   wire           to_link_done;
   wire           to_link_receive_overflow;
   wire           to_link_send_empty;
   wire           to_link_send_underrun;
   reg tx_reset_done_r;
   
      //debug port connections
   assign  to_link_FIS_rdy_de = to_link_FIS_rdy;
   assign  to_link_done_de = to_link_done;
   assign  to_link_receive_empty_de = rdata_empty;
   assign  to_link_receive_overflow_de = to_link_receive_overflow;
   assign  to_link_send_empty_de = to_link_send_empty;
   assign  to_link_send_underrun_de = to_link_send_underrun;
   
   assign  from_link_idle_de = from_link_idle;
   assign  from_link_ready_to_transmit_de = from_link_ready_to_transmit;
   assign  from_link_next_de = from_link_next;
   assign  from_link_data_en_de = from_link_data_en;
   assign  from_link_done_de = from_link_done;
   assign  from_link_err_de = from_link_err;
       
   assign  link_tx_data_de = TXDATA;
   assign  link_rx_data_de = RXDATA;
   assign rx_charisk_de = RXCHARISK0;
   assign from_link_data_de = from_link_data;
   assign to_link_data_de = to_link_data;
   assign tx_charisk_de = TXCHARISK;
   assign rxByteIsAligned_de = RXBYTEISALIGNED0;
   assign rxElecIdle_de = RXELECIDLE0;
   //assign rxReAlign_de = gt0_rxbyterealign_out;
   //assign rxCommaDet_de = gt0_rxcommadet_out;
   //assign tx_reset_done_de = tx_reset_done;
   //assign rx_reset_done_de = rx_reset_done;
   assign rx_start_de = rx_start;
	
   // signal assignments
   assign link_initialized   = from_link_initialized;
	
   always @(posedge logic_clk)
	   tx_reset_done_r <= tx_reset_done;
   
   Link Link0
     (
      .clk                         (logic_clk),
      .reset                       (gth_reset),
      
      .tx_reset_done     (tx_reset_done_r),
	  .rx_cominit_det	 (rx_cominit_det),
	  .rx_comwake_det	 (rx_comwake_det),
      .rx_elecidle       (RXELECIDLE0),
      .rx_charisk        (RXCHARISK0),
      .rx_datain         (RXDATA),
      .rx_byteisaligned  (RXBYTEISALIGNED0),
      .rx_start                    (rx_start),
	  .rx_reset_done			  (rx_reset_done),
	  .tx_cominit				  (tx_cominit),
	  .tx_comwake				  (tx_comwake),
      .tx_elecidle                 (TXELECIDLE),
      .tx_data                     (TXDATA),
      .tx_charisk                  (TXCHARISK),

      .from_link_comreset          (from_link_comreset),
      .from_link_initialized       (from_link_initialized),
      .from_link_idle              (from_link_idle),
      .from_link_ready_to_transmit (from_link_ready_to_transmit),
      .from_link_next              (from_link_next),
      .from_link_data              (from_link_data),
      .from_link_data_en           (from_link_data_en),
      .from_link_done              (from_link_done),
      .from_link_err               (from_link_err),

      .to_link_FIS_rdy             (to_link_FIS_rdy),
      .to_link_data                (to_link_data),
      .to_link_done                (to_link_done),
      .to_link_receive_empty       (rdata_empty),
      .to_link_receive_overflow    (to_link_receive_overflow),
      .to_link_send_empty          (to_link_send_empty),
      .to_link_send_underrun       (to_link_send_underrun),
      .tx_reset(tx_reset),
      
            .state_de (link_state_de),
           .rx_scramblerMask_de(rx_scramblerMask_de),
           .tx_scramblerMask_de(tx_scramblerMask_de),
           .tx_data_r0_de(tx_data_r0_de),
           .prim_hold_det_de(prim_hold_det_de),
           .crcReset_de(crcReset_de),
           .crcEn_de(crcEn_de),
           .crcCode_de(crcCode_de),
           .scramblerReset_de(scramblerReset_de),
           .scramblerEn_de(scramblerEn_de),
           .scramblerNoPause_de(scramblerNoPause_de),
           .align_countdown_de(align_countdown_de),
           .prim_r_err_det_de(prim_r_err_det_de)
      );

   Transport Transport0
     (
      .clk                         (logic_clk),
      .reset                       (from_link_comreset),

      // HBA main interface: input ports
      .cmd                         (cmd),
      .cmd_en                      (cmd_en),
      .lba                         (lba),
      .sectorcnt                   (sectorcnt),
      .wdata                       (wdata),
      .wdata_en                    (wdata_en),
      .rdata_next                  (rdata_next), 

      // HBA main interface: output ports
      .wdata_full                  (wdata_full),
      .rdata                       (rdata),
      .rdata_empty                 (rdata_empty),
      .cmd_failed                  (cmd_failed),
      .cmd_success                 (cmd_success),

      // HBA NCQ extension
      .ncq_wtag                    (ncq_wtag),
      .ncq_rtag                    (ncq_rtag),
      .ncq_idle                    (ncq_idle),
      .ncq_relinquish              (ncq_relinquish),
      .ncq_ready_for_wdata         (ncq_ready_for_wdata),
      .ncq_SActive                 (ncq_SActive),
      .ncq_SActive_valid           (ncq_SActive_valid),
      
      // Link module
      .from_link_idle              (from_link_idle),
      .from_link_ready_to_transmit (from_link_ready_to_transmit),
      .from_link_next              (from_link_next),
      .from_link_data              (from_link_data),
      .from_link_data_en           (from_link_data_en),
      .from_link_done              (from_link_done),
      .from_link_err               (from_link_err),

      .to_link_FIS_rdy             (to_link_FIS_rdy),
      .to_link_data                (to_link_data),
      .to_link_done                (to_link_done),
      .to_link_receive_overflow    (to_link_receive_overflow),
      .to_link_send_empty          (to_link_send_empty),
      .to_link_send_underrun       (to_link_send_underrun),
           .state_de (tran_state_de),
           .current_sectorcnt_de(current_sectorcnt_de),
           .wordcnt_en_de(wordcnt_en_de),
           .wordcnt_clear_de(wordcnt_clear_de),
           .wordcnt_de(wordcnt_de)
      );

endmodule