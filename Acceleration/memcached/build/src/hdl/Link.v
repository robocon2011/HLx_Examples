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
 * Module        : Link
 * Created       : April 08 2011
 * Last Update   : March 15 2012
 * Last Update   : December, rewritten by Lisa Liu
 * ---------------------------------------------------------------------------
 * Description   : Low-level SATA interface
 *                 - Link initialization on reset (OOB)
 *                 - Send FIS
 *                 - Receive FIS
 *                 - Scrambling/descrambling
 *                 - CRC32 generation/checking
 *                 - ALIGN insertion
 * ------------------------------------------------------------------------- */

`timescale 1 ns / 1 ps

module Link 
  (
   input         clk,
   input         reset,

   // GTH Tile -> RX signals
   input         tx_reset_done, 
	input			  rx_reset_done,
	input rx_cominit_det,
	input rx_comwake_det,
   input         rx_elecidle, // RX electrical idle
   input [3:0]   rx_charisk, // RX control value : rx_charisk[0] = 1 -> rx_datain[7:0] is K (control value) (e.g., 8'hBC = K28.5), rx_charisk[1] = 1 -> rx_datain[15:8] is K 
   input [31:0]  rx_datain, // RX data
   input         rx_byteisaligned, // RX byte alignment completed
   output reg    rx_start, // first initiate GTH RX and start receiving data
	output tx_cominit,
	output tx_comwake,
   output        tx_elecidle, // TX electircal idel
   output [31:0] tx_data, // TX data outgoing 
   output        tx_charisk, // TX byted is K character
   output   tx_reset,

   input         to_link_FIS_rdy,
   input [31:0]  to_link_data,
   input         to_link_done,
   input         to_link_receive_empty,
   input         to_link_receive_overflow,
   input         to_link_send_empty,
   input         to_link_send_underrun,

   output reg    from_link_comreset,
   output reg    from_link_initialized,
   output reg    from_link_idle,
   output reg    from_link_ready_to_transmit,
   output        from_link_next,
   output [31:0] from_link_data,
   output        from_link_data_en,
   output reg    from_link_done,
   output reg    from_link_err,
   
   //debug port
   output [5:0] state_de,
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
   output prim_r_err_det_de
   );

   // --- states link layer FSM ----------------------------------
   
   localparam [5:0]
      
     // reset states
	  IDLE						 = 0,
     HOST_COMRESET          = 1,
     WAIT_DEV_COMINIT       = 2,
     HOST_COMWAKE           = 3, 
     WAIT_DEV_COMWAKE       = 4,
     WAIT_AFTER_COMWAKE     = 5,
     WAIT_AFTER_COMWAKE1    = 6,
     HOST_D10_2             = 7,
     HOST_SEND_ALIGN        = 8,
     WAIT_LINK_READY        = 9,
     
     LINK_IDLE        		 = 10,
     
     RECEIVEFIS_R_RDY       = 11,
     RECEIVEFIS_R_IP        = 12,
     RECEIVEFIS_HOLDA       = 13,
     RECEIVEFIS_WAIT_HOLD   = 14,
     RECEIVEFIS_R_OK        = 15,
	 
	  SENDFIS_X_RDY          = 16,
     SENDFIS_WAIT_BUFFER    = 17,   
     SENDFIS_SOF            = 18,
     SENDFIS_PAYLOAD        = 19,
     SENDFIS_CRC            = 20,
     SENDFIS_EOF            = 21,
     SENDFIS_WTRM           = 22,
     SENDFIS_SYNC           = 23,
     SENDFIS_SYNC_ERR       = 24,
     SENDFIS_PAYLOAD_HOLDA  = 25,
     SENDFIS_WAIT_HOLD 		 = 26;
   
   
	reg [5:0] 					currState;
   
   // --- Encoding of SATA primitives ----------------------------

   localparam [31:0]
     PRIM_DIALTONE = 32'h4A4A4A4A, 
	  PRIM_ALIGN    = 32'h7B4A4ABC,
     PRIM_CONT     = 32'h9999AA7C,
     PRIM_DMAT     = 32'h3636B57C,
     PRIM_EOF      = 32'hD5D5B57C,
     PRIM_HOLD     = 32'hD5D5AA7C,
     PRIM_HOLDA    = 32'h9595AA7C,
     PRIM_PMACK    = 32'h9595957C,
     PRIM_PMNAK    = 32'hF5F5957C,
     PRIM_PMREQ_P  = 32'h1717B57C,
     PRIM_PMREQ_S  = 32'h7575957C,
     PRIM_R_ERR    = 32'h5656B57C,
     PRIM_R_IP     = 32'h5555B57C,
     PRIM_R_OK     = 32'h3535B57C,
     PRIM_R_RDY    = 32'h4A4A957C,
     PRIM_SOF      = 32'h3737B57C,
     PRIM_SYNC     = 32'hB5B5957C,
     PRIM_WTRM     = 32'h5858B57C,
     PRIM_X_RDY    = 32'h5757B57C;

   // --- SATA primitive detected --------------------------------

   wire                    
                           prim_align_det,
                           prim_cont_det,
                           prim_dmat_det,
                           prim_eof_det,
                           prim_hold_det,
                           prim_holda_det,
                           prim_pmack_det,
                           prim_pmnak_det,
                           prim_pmreq_p_det,
                           prim_pmreq_s_det,
                           prim_r_err_det,
                           prim_r_ip_det,
                           prim_r_ok_det,
                           prim_r_rdy_det,
                           prim_sof_det,
                           prim_sync_det,
                           prim_wtrm_det,
                           prim_x_rdy_det;
                           
    reg prim_hold_det_r1, prim_hold_det_r2;
															
	reg 							prim_sync_det_r1, prim_sync_det_r2;
	reg							prim_det_r1;
	reg							prim_align_det_r1, prim_align_det_r2;
	reg                         prim_cont_det_r1;

   reg [17:0]              count;
   reg                     count_en;
 
   reg [8:0]               align_prim_cnt;
   reg                     align_insert;
   reg [2:0]               align_countdown;

   // RX register chain
   reg [31:0]              rx_datain_r1, rx_datain_r2, rx_datain_r3, rx_datain_r4;
	reg [3:0] 					rx_charisk_r1;

   reg                     rx_datain_r2_valid;
   reg                     rx_datain_r3_valid;
   reg                     rx_datain_r4_valid;

   reg [31:0]              tx_data_r0, tx_data_r1, tx_data_r2, tx_data_r3;
	reg                     tx_charisk_r0,  tx_charisk_r1,  tx_charisk_r2,  tx_charisk_r3;
	reg							tx_cominit_r0, tx_cominit_r1, tx_cominit_r2, tx_cominit_r3;
	reg							tx_comwake_r0, tx_comwake_r1, tx_comwake_r2, tx_comwake_r3;
   reg                     tx_elecidle_r0, tx_elecidle_r1, tx_elecidle_r2, tx_elecidle_r3;
   reg    tx_reset_r;
	
	wire [31:0] 				scramblerMask, crcCode, crcData;
	wire 							scramblerReset, scramblerEn, scramblerNoPause, crcReset, crcEn;
	wire [31:0]							rx_scramblerMask, tx_scramblerMask;
	reg							tx_scramblerReset_r0, rx_scramblerReset_r0, tx_scramblerEn_r0, rx_scramblerEn_r0, tx_scramblerNoPause_r0, tx_scramblerNoPause_r1;
	reg							tx_crcEn_r0, tx_crcReset_r0, rx_crcReset_r0, from_link_next_r0;
	reg							rx_crcMatch_r0;
	
	reg 							to_link_FIS_rdy_r1;
	reg			prim_x_rdy_det_r;
	
	assign state_de = currState;
	assign rx_scramblerMask_de = rx_scramblerMask;
	assign tx_scramblerMask_de = tx_scramblerMask;
	assign tx_data_r0_de = tx_data_r0;
	assign prim_hold_det_de = prim_hold_det;
	assign crcReset_de = crcReset;
	assign crcEn_de = crcEn;
	assign crcCode_de = crcCode;
	assign scramblerReset_de = scramblerReset;
    assign scramblerEn_de = scramblerEn;
    assign scramblerNoPause_de = scramblerNoPause;
    assign align_countdown_de = align_countdown;
    assign prim_r_err_det_de = prim_r_err_det;
   
	assign tx_elecidle = tx_elecidle_r3;
	assign tx_cominit = tx_cominit_r3;
	assign tx_comwake = tx_comwake_r3;
	assign tx_data =  tx_data_r3;
	       
	assign tx_charisk = tx_charisk_r3;
	assign tx_reset = tx_reset_r;
	
	always @(posedge clk)
		if (reset)
			from_link_comreset <= 1'b1;
		else if (currState == HOST_COMRESET)
			from_link_comreset <= 1'b1;
		else
			from_link_comreset <= 1'b0;
			
	always @(posedge clk)
		if (reset) 
			from_link_idle <= 1'b0;
		else if (currState == LINK_IDLE) 
			from_link_idle <= 1'b1;
		else
			from_link_idle <= 1'b0;
			
	//from_link_ready_to_transmit
	always @(posedge clk)
		if (reset)
			from_link_ready_to_transmit <= 1'b0;
		else if ((currState == SENDFIS_X_RDY) & prim_r_rdy_det)
			from_link_ready_to_transmit <= 1'b1;
		else if (currState == SENDFIS_WAIT_BUFFER)
			from_link_ready_to_transmit <= 1'b1;
		else
			from_link_ready_to_transmit <= 1'b0;
			
	assign from_link_next = (from_link_next_r0 & ~prim_hold_det) | 
	                        ((currState == SENDFIS_WAIT_HOLD) & prim_r_ip_det) |
	                        ((currState == SENDFIS_PAYLOAD_HOLDA) & prim_r_ip_det); //tx_crcEn_r0;
	assign from_link_data    = rx_datain_r4;
   assign from_link_data_en = rx_datain_r4_valid;
	
	always @(posedge clk)
		if (reset) begin
			from_link_done <= 1'b0;
			from_link_err <= 1'b0;
		end
		// If trying to send FIS while we are receiving -> abort receive request
		else if ((currState == RECEIVEFIS_R_RDY) & to_link_FIS_rdy) begin
			from_link_done <= 1'b1;
			from_link_err <= 1'b1; 
		end
		else if ((currState == RECEIVEFIS_R_OK) & (prim_sync_det | prim_x_rdy_det)) begin
			from_link_err <= ~rx_crcMatch_r0;
			from_link_done <= 1'b1;
		end
		else if ((currState == SENDFIS_X_RDY) & prim_x_rdy_det) begin
			from_link_done <= 1'b0;
			from_link_err <= 1'b1;
		end
		else if ((currState == SENDFIS_SYNC) & prim_sync_det) begin
			from_link_done <= 1'b1;
			from_link_err <= 1'b0;
		end
		else if (((currState == RECEIVEFIS_R_IP) | (currState == RECEIVEFIS_HOLDA) | (currState == RECEIVEFIS_WAIT_HOLD) |
		          (currState == SENDFIS_SOF) | (currState == SENDFIS_PAYLOAD) | (currState == SENDFIS_CRC) |
		          (currState == SENDFIS_EOF) | (currState == SENDFIS_WTRM) | (currState == SENDFIS_PAYLOAD_HOLDA) |
		          (currState == SENDFIS_WAIT_HOLD) | (currState == SENDFIS_SYNC_ERR))
		           & prim_sync_det)begin
			from_link_done <= 1'b1;
			from_link_err <= 1'b1;
		end
		else begin
			from_link_done <= 1'b0;
			from_link_err <= 1'b0;
		end
	
	always @(posedge clk) begin
		rx_charisk_r1 <= rx_charisk;
		rx_datain_r1 <= rx_datain;
		to_link_FIS_rdy_r1 <= to_link_FIS_rdy;
		prim_x_rdy_det_r <= prim_x_rdy_det;
	end
	
	always @(posedge clk) begin
		tx_elecidle_r1 <= tx_elecidle_r0;
		tx_elecidle_r2 <= tx_elecidle_r1;
		tx_elecidle_r3 <= tx_elecidle_r2;
		
		tx_cominit_r1 <= tx_cominit_r0;
		tx_cominit_r2 <= tx_cominit_r1;
		tx_cominit_r3 <= tx_cominit_r2;
		tx_comwake_r1 <= tx_comwake_r0;
		tx_comwake_r2 <= tx_comwake_r1;
		tx_comwake_r3 <= tx_comwake_r2;
	end
	
	 // primitive detection
   assign prim_align_det   = (rx_datain_r1 == PRIM_ALIGN[31:0]) & (rx_charisk_r1 == 4'b0001); 
   assign prim_cont_det    = (rx_datain_r1 == PRIM_CONT[31:0]) & (rx_charisk_r1 == 4'b0001); 
   assign prim_dmat_det    = (rx_datain_r1 == PRIM_DMAT[31:0]) & (rx_charisk_r1 == 4'b0001); 
   assign prim_eof_det     = (rx_datain_r1 == PRIM_EOF[31:0]) & (rx_charisk_r1 == 4'b0001); 
   assign prim_hold_det    = (rx_datain_r1 == PRIM_HOLD[31:0]) & (rx_charisk_r1 == 4'b0001); 
   assign prim_holda_det   = (rx_datain_r1 == PRIM_HOLDA[31:0]) & (rx_charisk_r1 == 4'b0001);
   assign prim_pmack_det   = (rx_datain_r1 == PRIM_PMACK[31:0]) & (rx_charisk_r1 == 4'b0001);
   assign prim_pmnak_det   = (rx_datain_r1 == PRIM_PMNAK[31:0]) & (rx_charisk_r1 == 4'b0001);
   assign prim_pmreq_p_det = (rx_datain_r1 == PRIM_PMREQ_P[31:0]) & (rx_charisk_r1 == 4'b0001);
   assign prim_pmreq_s_det = (rx_datain_r1 == PRIM_PMREQ_S[31:0]) & (rx_charisk_r1 == 4'b0001);
   assign prim_r_err_det   = (rx_datain_r1 == PRIM_R_ERR[31:0]) & (rx_charisk_r1 == 4'b0001); 
   assign prim_r_ip_det    = (rx_datain_r1 == PRIM_R_IP[31:0]) & (rx_charisk_r1 == 4'b0001); 
   assign prim_r_ok_det    = (rx_datain_r1 == PRIM_R_OK[31:0]) & (rx_charisk_r1 == 4'b0001); 
   assign prim_r_rdy_det   = (rx_datain_r1 == PRIM_R_RDY[31:0]) & (rx_charisk_r1 == 4'b0001);
   assign prim_sof_det     = (rx_datain_r1 == PRIM_SOF[31:0]) & (rx_charisk_r1 == 4'b0001);
   assign prim_sync_det    = (rx_datain_r1 == PRIM_SYNC[31:0]) & (rx_charisk_r1 == 4'b0001);
   assign prim_wtrm_det    = (rx_datain_r1 == PRIM_WTRM[31:0]) & (rx_charisk_r1 == 4'b0001);
   assign prim_x_rdy_det   = (rx_datain_r1 == PRIM_X_RDY[31:0]) & (rx_charisk_r1 == 4'b0001);
	
	always @(posedge clk) 
		if (reset) begin
			prim_sync_det_r1 <= 1'b0;
			prim_sync_det_r2 <= 1'b0;
			prim_det_r1 <= 1'b0;
			prim_align_det_r1 <= 1'b0;
			prim_align_det_r2 <= 1'b0;
			
			prim_hold_det_r1 <= 1'b0;
			prim_hold_det_r2 <= 1'b0;
		end
		else begin
			prim_sync_det_r1 <= prim_sync_det;
			prim_sync_det_r2 <= prim_sync_det_r1;
			prim_det_r1  <= (rx_charisk == 4'b0001);
			prim_align_det_r1 <= prim_align_det;
			prim_align_det_r2 <= prim_align_det_r1;
			
			prim_hold_det_r1 <= prim_hold_det;
			prim_hold_det_r2 <= prim_hold_det_r1;
			prim_cont_det_r1 <= prim_cont_det;
		end
		
  // At least every 1024 bytes or  256 32-bit words we need to insert two align primitives
   always@(posedge clk) begin
      if (reset) begin
         align_prim_cnt <= 0;
         align_insert   <= 0;
      end
      else begin
         if (align_prim_cnt == 255) begin //255) begin 
            align_insert <= 1'b1;
				align_prim_cnt <= 0;
			end
			else begin
				align_insert <= 1'b0;
				align_prim_cnt <= align_prim_cnt+1;
         end
      end
   end
	
	CRC_32 CRC_32_0
   (
      .clk    (clk),
      .reset  (crcReset), // reset is triggered before reception or transmission of a FIS
      .enable (crcEn),
      .data   (crcData),
      .crc    (crcCode)
   );
	assign crcReset = tx_crcReset_r0 | rx_crcReset_r0;
	assign crcEn = from_link_next | rx_datain_r4_valid; //(tx_crcEn_r0 & ~to_link_send_empty) | rx_datain_r4_valid;
	assign crcData = (from_link_next)?to_link_data: rx_datain_r4; //(tx_crcEn_r0)? to_link_data: rx_datain_r4;
	
	Scrambler Scrambler0 
   (
      .clk          (clk),
      .reset        (scramblerReset), // reset is triggered before reception or transmission of a FIS
      .enable       (scramblerEn),
      .nopause      (scramblerNoPause),
      .scramblemask (scramblerMask)
    );
	assign scramblerReset = rx_scramblerReset_r0 | tx_scramblerReset_r0;
	assign scramblerEn	 = rx_scramblerEn_r0 | tx_scramblerEn_r0;
	assign scramblerNoPause = rx_datain_r2_valid | tx_scramblerNoPause_r0;
	
	assign rx_scramblerMask = (rx_datain_r3_valid)? scramblerMask: 32'd0;
	
	assign tx_scramblerMask = (tx_scramblerNoPause_r1)? scramblerMask: 32'd0;
	always @(posedge clk) 
		if (reset) begin
			rx_datain_r2_valid <= 1'b0;
			rx_datain_r3_valid <= 1'b0;
			rx_datain_r4_valid <= 1'b0;
			
			tx_scramblerNoPause_r1 <= 1'b0;
			tx_data_r3 <= 32'd0;
			tx_charisk_r3 <= 1'b0;
		end
		else begin    // original rx_datain_r2_valid condition when state is RECEIVEFIS_IP, ~prim_align_det & ~prim_eof_det & ~prim_wtrm_det & ~prim_hold_det) |
			rx_datain_r2_valid <= ((currState == RECEIVEFIS_R_IP) & ~prim_det_r1) | 
			                      ((currState == RECEIVEFIS_HOLDA) & ~prim_det_r1 & prim_hold_det_r1 ); // consider one cycle HOLD primitive sent from device
			rx_datain_r3_valid <= rx_datain_r2_valid;
			rx_datain_r4_valid <= rx_datain_r3_valid;
			
			rx_datain_r2 <= rx_datain_r1;
			rx_datain_r3 <= rx_datain_r2;
			rx_datain_r4 <= rx_datain_r3 ^ rx_scramblerMask;
			
			
			tx_scramblerNoPause_r1 <= tx_scramblerNoPause_r0;
			
			tx_data_r1 <= tx_data_r0;
			tx_data_r2 <= tx_data_r1;
			tx_data_r3 <= tx_data_r2 ^ tx_scramblerMask;
			
			tx_charisk_r1 <= tx_charisk_r0;
			tx_charisk_r2 <= tx_charisk_r1;
			tx_charisk_r3 <= tx_charisk_r2;
		end
	
   always@(posedge clk) begin
      if (reset) begin
         currState <= IDLE; //HOST_COMRESET;
			count_en <= 1'b0;
			rx_start <= 1'b0;
			tx_cominit_r0 <= 1'b0;
			tx_comwake_r0 <= 1'b0;
			tx_elecidle_r0 <= 1'b1;
			tx_data_r0 <= 32'd0;
			align_countdown <= 3'd0;
			tx_charisk_r0 <= 1'b0;
			tx_crcReset_r0 <= 1'b1;
			rx_crcReset_r0 <= 1'b1;
			tx_crcEn_r0 <= 1'b0;
			from_link_next_r0 <= 1'b0;
			rx_scramblerReset_r0 <= 1'b1;
			rx_scramblerEn_r0 <= 1'b0;
			tx_scramblerReset_r0 <= 1'b1;
			tx_scramblerNoPause_r0 <= 1'b0;
			from_link_initialized <= 1'b0;
			tx_reset_r <= 1'b0;
      end
      else begin   
			count_en <= 1'b0;
			tx_cominit_r0 <= 1'b0;
			tx_comwake_r0 <= 1'b0;
			tx_crcReset_r0 <= 1'b0;
			rx_crcReset_r0 <= 1'b0;
			rx_scramblerReset_r0 <= 1'b0;
			rx_scramblerEn_r0 <= 1'b0;
			tx_scramblerReset_r0 <= 1'b0;
			tx_scramblerEn_r0 <= 1'b0;
			tx_scramblerNoPause_r0 <= 1'b0;
			tx_reset_r <= 1'b0;
         case (currState)
			  IDLE: begin
						 if (tx_reset_done)
							currState <= HOST_COMRESET;
					  end
           // --- Link initialization -------------------------------------------------
			  //OOB signaling and Powerup state machine
           HOST_COMRESET: begin
				  rx_start <= 1'b0;
				  tx_elecidle_r0 <= 1'b1;
				  tx_data_r0 <= PRIM_DIALTONE[31:0];
				  tx_charisk_r0 <= 1'b0;
				  from_link_initialized <= 1'b0;
				  if (count == 18'h00190) begin
					  currState <= WAIT_DEV_COMINIT;
				  end
				  else begin
                 currState <= HOST_COMRESET;
					  tx_cominit_r0 <= 1'b1;
					  count_en <= 1'b1;
				  end
           end
           
           WAIT_DEV_COMINIT: begin
              //device cominit detected
              if (rx_cominit_det)
                 currState <= HOST_COMWAKE;
              else if (count == 18'h1fffe) begin //if (count == 18'h203AD) begin  //restart comreset after no cominit for at least 880us
					  currState <= HOST_COMRESET;
					  count_en <= 1'b0;
                 tx_cominit_r0 <= 1'b0;
					  tx_comwake_r0 <= 1'b0;
				  end
              else begin
                 currState <= WAIT_DEV_COMINIT;
					  count_en <= 1'b1;
				  end
           end

           HOST_COMWAKE: begin
              //if (count == 18'h00136)
				  //assert COMWAKE FOR 2.67us
				  if (count == 18'h00190)
                 currState     <= WAIT_DEV_COMWAKE;
              else begin
                 currState     <= HOST_COMWAKE;
					  if (~rx_cominit_det) begin
							count_en <= 1'b1;
							tx_comwake_r0 <= 1'b1;
					  end
				  end
           end
           
           WAIT_DEV_COMWAKE: begin
              if (rx_comwake_det)//device comwake detected
                 currState <= WAIT_AFTER_COMWAKE;
              else if (count == 18'h1fffe) begin //if (count == 18'h203AD) begin//restart comreset after no comwake for 880us
                 currState <= HOST_COMRESET;
					  count_en <= 1'b0;
					  tx_cominit_r0 <= 1'b0;
					  tx_comwake_r0 <= 1'b0;
				  end
              else begin
                 currState <= WAIT_DEV_COMWAKE;
					  count_en <= 1'b1;
				  end
           end

           WAIT_AFTER_COMWAKE: begin
              //if (count == 6'h3F) 
				  if (~rx_comwake_det)
				     currState <= WAIT_AFTER_COMWAKE1;
              else begin
                 currState <= WAIT_AFTER_COMWAKE;
					  count_en <= 1'b1;
				  end
           end

           WAIT_AFTER_COMWAKE1: begin
              if(~rx_elecidle) begin
                 currState <= HOST_D10_2;
					  tx_elecidle_r0 <= 1'b0;
				  end
              else
                 currState <= WAIT_AFTER_COMWAKE1;
           end
           
           HOST_D10_2: begin 
              // if not rx byte is alinged -> something went wrong (will eventually reset)
              // wait until we see first ALIGN primitive, if we can detect an ALIGN primitive
              // this means that we actually understand the bit stream comming from the drive.
              //if(prim_align_det & rx_byteisaligned) begin
				  if (prim_align_det & prim_align_det_r1 & prim_align_det_r2) begin
					  //rx_start <= 1'b1;
					  currState    <= HOST_SEND_ALIGN;
					  tx_data_r0 <= PRIM_ALIGN[31:0];
					  tx_charisk_r0 <= 1'b1;
					  
				  end
              else if (count == 18'h1fffe) begin //if (count == 18'h203AD) begin // restart comreset after 880us
                 currState <= HOST_COMRESET;
					  count_en <= 1'b0;
					  tx_cominit_r0 <= 1'b0;
					  tx_comwake_r0 <= 1'b0;
					  
				  end
              else begin
                 currState <= HOST_D10_2;
					  count_en <= 1'b1;
				  end
           end
           
           HOST_SEND_ALIGN: begin 
               //three back-to-back non-align primitives detected
				  if (prim_sync_det & prim_sync_det_r1) begin // & prim_sync_det_r2) begin
                        currState    <= WAIT_LINK_READY;
				  end
              else begin
                 currState <= HOST_SEND_ALIGN;
				  end
           end

           WAIT_LINK_READY: begin
              if(count == 18'h203AD) begin// we have waited for link to get up for too long -> reset
                 currState <= HOST_COMRESET;
					  count_en <= 1'b0;
					  tx_cominit_r0 <= 1'b0;
					  tx_comwake_r0 <= 1'b0;
					  
				  end
              else if (~rx_elecidle ) begin// link is now ready
					  currState <= LINK_IDLE;
					  count_en <= 1'b0;
					  tx_data_r0 <= PRIM_SYNC[31:0];
					  tx_charisk_r0 <= 1'b1;
				  end
              else begin// link is not ready yet -> rx is still idle
                 currState <= WAIT_LINK_READY;
					  count_en <= 1'b1;
				  end
           end

           LINK_IDLE: begin
					   from_link_initialized <= 1'b1;
					if (to_link_FIS_rdy ) begin
						currState <= SENDFIS_X_RDY;
						tx_data_r0 <= PRIM_X_RDY[31:0];
						tx_charisk_r0 <= 1'b1;
						tx_crcReset_r0 <= 1'b1;
						tx_scramblerReset_r0 <= 1'b1;
					end
					else if (prim_x_rdy_det_r) begin
						currState <= RECEIVEFIS_R_RDY;
						tx_data_r0 <= PRIM_R_RDY[31:0];
						tx_charisk_r0 <= 1'b1;
						rx_crcReset_r0 <= 1'b1;
						rx_scramblerReset_r0 <= 1'b1;
					end
					else begin
						currState <= LINK_IDLE;
						if (align_insert)
							align_countdown <= 2;
						if (align_countdown != 0) begin
							align_countdown <= align_countdown - 1;
							tx_data_r0 <= PRIM_ALIGN[31:0];
						end
						else begin
							tx_data_r0 <= PRIM_SYNC[31:0];
						end
					end
			  end
			  //receive frame information structure (FIS)
			  RECEIVEFIS_R_RDY: begin
					rx_crcMatch_r0 <= 1'b0;
					if (prim_sof_det) begin
						currState <= RECEIVEFIS_R_IP;
						tx_data_r0 <= PRIM_R_IP[31:0];
						tx_charisk_r0 <= 1'b1;
						rx_scramblerEn_r0 <= 1'b1;
					end
					else if (prim_wtrm_det) begin
						currState <= LINK_IDLE;
						tx_data_r0 <= PRIM_SYNC[31:0];
						tx_charisk_r0 <= 1'b1;
					end
					else begin
						currState <= RECEIVEFIS_R_RDY;
						if (align_insert)
							align_countdown <= 2;
						if (align_countdown != 0) begin
							align_countdown <= align_countdown - 1;
							tx_data_r0 <= PRIM_ALIGN[31:0];
						end
						else begin
							tx_data_r0 <= PRIM_R_RDY[31:0];
						end
					end
			  end
			  RECEIVEFIS_R_IP: begin
					if (prim_wtrm_det) begin
						currState <= RECEIVEFIS_R_OK;
						tx_data_r0 <= PRIM_R_OK[31:0];
						tx_charisk_r0 <= 1'b1;
						rx_crcReset_r0 <= prim_eof_det;
					end
					else if (prim_hold_det) begin
						currState <= RECEIVEFIS_HOLDA;
						tx_charisk_r0 <= 1'b1;
					end
					else if (prim_sync_det) begin
					   	currState <= LINK_IDLE;
                        tx_data_r0 <= PRIM_SYNC;
                        tx_charisk_r0 <= 1'b1;
					end
					else begin
						currState <= RECEIVEFIS_R_IP;
						if (align_insert)
							align_countdown <= 2;
						if (align_countdown != 0) begin
							align_countdown <= align_countdown - 1;
							tx_data_r0 <= PRIM_ALIGN[31:0];
						end
						else begin
							tx_data_r0 <= PRIM_R_IP[31:0];
						end
					end
			  end
			  RECEIVEFIS_R_OK: begin
					if (rx_datain_r4_valid) begin
						rx_crcMatch_r0 <= (crcCode == rx_datain_r4);
					end
					if (prim_sync_det | prim_x_rdy_det) begin
						rx_start <= 1'b1;
						currState <= LINK_IDLE;
						tx_data_r0 <= PRIM_SYNC[31:0];
						tx_charisk_r0 <= 1'b1;
					end
					else begin
						currState <= RECEIVEFIS_R_OK;
						if (align_insert)
							align_countdown <= 2;
						if (align_countdown != 0) begin
							align_countdown <= align_countdown - 1;
							tx_data_r0 <= PRIM_ALIGN[31:0];
						end
						else begin
							tx_data_r0 <= PRIM_R_OK[31:0];
						end
					end
			  end
			  RECEIVEFIS_HOLDA: begin
					if (prim_wtrm_det) begin
						currState <= RECEIVEFIS_R_OK;
						tx_data_r0 <= PRIM_R_OK[31:0];
						tx_charisk_r0 <= 1'b1;
					end
					else if (prim_cont_det) begin
						currState <= RECEIVEFIS_WAIT_HOLD;
						tx_data_r0 <= PRIM_HOLDA[31:0];
						tx_charisk_r0 <= 1'b1;
					end
					//if not detect hold primitive anymore
					else if ((rx_datain != PRIM_HOLD) & (rx_datain != PRIM_CONT) & (rx_datain != PRIM_SYNC)) begin
					   currState <= RECEIVEFIS_R_IP;
					   tx_data_r0 <= PRIM_R_IP;
                       tx_charisk_r0 <= 1'b1;
					end
					else if (prim_sync_det) begin
					   	currState <= LINK_IDLE;
                        tx_data_r0 <= PRIM_SYNC;
                        tx_charisk_r0 <= 1'b1;
					end
					else begin
						currState <= RECEIVEFIS_HOLDA;
						if (align_insert)
							align_countdown <= 2;
						if (align_countdown != 0) begin
							align_countdown <= align_countdown - 1;
							tx_data_r0 <= PRIM_ALIGN[31:0];
						end
						else begin
							tx_data_r0 <= PRIM_HOLDA[31:0];
						end
					end
			  end
			  RECEIVEFIS_WAIT_HOLD: begin
					if (prim_wtrm_det) begin
						currState <= RECEIVEFIS_R_OK;
						tx_data_r0 <= PRIM_R_OK;
						tx_charisk_r0 <= 1'b1;
					end
					else if ((prim_det_r1 & ~prim_align_det) | prim_r_ip_det) begin // & ~prim_hold_det_r1 & (rx_datain != PRIM_HOLD)) | prim_r_ip_det) begin  //(prim_hold_det & (rx_datain != PRIM_HOLD) & (rx_datain != PRIM_CONT) ) begin
						currState <= RECEIVEFIS_R_IP;
						tx_data_r0 <= PRIM_R_IP;
						tx_charisk_r0 <= 1'b1;
					end
					else if (prim_sync_det) begin
					   	currState <= LINK_IDLE;
                        tx_data_r0 <= PRIM_SYNC;
                        tx_charisk_r0 <= 1'b1;
					end
					else begin
						currState <= RECEIVEFIS_WAIT_HOLD;
						if (align_insert)
							align_countdown <= 2;
						if (align_countdown != 0) begin
							align_countdown <= align_countdown - 1;
							tx_data_r0 <= PRIM_ALIGN[31:0];
						end
						else begin
							tx_data_r0 <= PRIM_HOLDA[31:0];
						end
					end
			  end
			  //send frame information structure (FIS)
			  SENDFIS_X_RDY: begin
			        if (prim_r_err_det) begin
			             tx_reset_r <= 1'b1;
			        end
					if (prim_r_rdy_det) begin
						currState <= SENDFIS_WAIT_BUFFER;
						tx_data_r0 <= PRIM_X_RDY[31:0];
						tx_charisk_r0 <= 1'b1;
					end
					else if (prim_x_rdy_det) begin
						currState <= LINK_IDLE;
						tx_data_r0 <= PRIM_SYNC;
						tx_charisk_r0 <= 1'b1;
					end
					else begin
						currState <= SENDFIS_X_RDY;
						if (align_insert)
							align_countdown <= 2;
					    if (align_countdown != 0) begin
							align_countdown <= align_countdown - 1;
							tx_data_r0 <= PRIM_ALIGN[31:0];
						end
						else begin
							tx_data_r0 <= PRIM_X_RDY[31:0];
			                /*if (prim_r_err_det) begin
                                  rx_start <= 1'b0;
                            end
                            else begin
                                rx_start <= 1'b1;
                            end*/
						end
					end
			  end
			  SENDFIS_WAIT_BUFFER: begin
				    if (align_insert) begin
							align_countdown <= 2;
							currState <= SENDFIS_WAIT_BUFFER;
							tx_data_r0 <= PRIM_X_RDY[31:0];
							tx_charisk_r0 <= 1'b1;
					end
					else if (align_countdown != 0) begin
							align_countdown <= align_countdown - 1;
							tx_data_r0 <= PRIM_ALIGN[31:0];
							tx_charisk_r0 <= 1'b1;
							currState <= SENDFIS_WAIT_BUFFER;
					end
					else if (~to_link_send_underrun) begin
                    		currState <= SENDFIS_SOF;
                    		tx_data_r0 <= PRIM_SOF[31:0];
                    		tx_charisk_r0 <= 1'b1;
                    		tx_crcEn_r0 <= 1'b1;
                    		from_link_next_r0 <= 1'b1;
                    end
					else begin
							tx_data_r0 <= PRIM_X_RDY[31:0];
							tx_charisk_r0 <= 1'b1;
							currState <= SENDFIS_WAIT_BUFFER;
					end
			  end
			  SENDFIS_SOF: begin
			        if (prim_sync_det) begin
			             currState <= LINK_IDLE;
                         tx_data_r0 <= PRIM_SYNC;
                         tx_charisk_r0 <= 1'b1;
			        end
			        else begin
					   currState <= SENDFIS_PAYLOAD;
					   tx_data_r0 <= to_link_data[31:0];
					   tx_charisk_r0 <= 1'b0;
					   tx_scramblerEn_r0 <= 1'b1;
					end
			  end
			  SENDFIS_PAYLOAD: begin
					tx_scramblerNoPause_r0 <= ~tx_charisk_r0;
					if (to_link_send_empty & to_link_done) begin
						currState <= SENDFIS_CRC;
						tx_data_r0 <= crcCode;
						tx_charisk_r0 <= 1'b0;
						tx_crcEn_r0 <= 1'b0;
						from_link_next_r0 <= 1'b0;
						tx_crcReset_r0 <= 1'b1;
					end
					else if (~to_link_send_empty & ~to_link_done & prim_hold_det) begin
						currState <= SENDFIS_PAYLOAD_HOLDA;
						tx_data_r0 <= PRIM_HOLDA[31:0];
						tx_charisk_r0 <= 1'b1;
						tx_crcEn_r0 <= 1'b0;
						from_link_next_r0 <= 1'b0;
					end
					else if (prim_sync_det) begin
					   	currState <= LINK_IDLE;
                        tx_data_r0 <= PRIM_SYNC;
                        tx_charisk_r0 <= 1'b1;
                        tx_crcEn_r0 <= 1'b0;
                        from_link_next_r0 <= 1'b0;
                        tx_crcReset_r0 <= 1'b1;
					end
					else begin
						currState <= SENDFIS_PAYLOAD;
						if (align_insert) begin
							align_countdown <= 2;
							from_link_next_r0 <= 1'b0;
							tx_data_r0 <= to_link_data;
                            tx_charisk_r0 <= 1'b0;
						end
						else if (align_countdown != 0) begin
							align_countdown <= align_countdown - 1;
							tx_data_r0 <= PRIM_ALIGN[31:0];
							tx_charisk_r0 <= 1'b1;
							tx_crcEn_r0 <= 1'b0;
							if (align_countdown == 1) begin
							     from_link_next_r0 <= 1'b1;
							end
							else begin
							     from_link_next_r0 <= 1'b0;
							end
						end
						else begin
							tx_data_r0 <= to_link_data;
							tx_charisk_r0 <= 1'b0;
							tx_crcEn_r0 <= 1'b1;
							from_link_next_r0 <= 1'b1;
						end
					end
			  end
			  SENDFIS_CRC: begin
					tx_crcEn_r0 <= 1'b0;
					from_link_next_r0 <= 1'b0;
					tx_scramblerNoPause_r0 <= 1'b1;
					if (prim_sync_det) begin
					   	currState <= LINK_IDLE;
                        tx_data_r0 <= PRIM_SYNC;
                        tx_charisk_r0 <= 1'b1;
					end
					else begin
						currState <= SENDFIS_EOF;
                    	tx_data_r0 <= PRIM_EOF[31:0];
                    	tx_charisk_r0 <= 1'b1;
                    end
			  end
			  SENDFIS_EOF: begin
					if (prim_sync_det) begin
                       	currState <= LINK_IDLE;
                        tx_data_r0 <= PRIM_SYNC;
                        tx_charisk_r0 <= 1'b1;
                    end
                    else begin
                        currState <= SENDFIS_WTRM;
                    	tx_data_r0 <= PRIM_WTRM[31:0];
                    	tx_charisk_r0 <= 1'b1;
                    	tx_scramblerNoPause_r0 <= 1'b0;
                    end
			  end
			  SENDFIS_WTRM: begin
					if (prim_r_ok_det) begin
						currState <= SENDFIS_SYNC;
						tx_data_r0 <= PRIM_SYNC[31:0];
						tx_charisk_r0 <= 1'b1;
					end
					else if (prim_r_err_det | prim_sync_det) begin
						currState <= SENDFIS_SYNC_ERR;
						tx_data_r0 <= PRIM_SYNC[31:0];
						tx_charisk_r0 <= 1'b1;
					end
					else if (prim_sync_det) begin
                       	currState <= LINK_IDLE;
                        tx_data_r0 <= PRIM_SYNC;
                        tx_charisk_r0 <= 1'b1;
                    end
					else begin
						currState <= SENDFIS_WTRM;
						if (align_insert)
							align_countdown <= 2;
						if (align_countdown != 0) begin
							align_countdown <= align_countdown - 1;
							tx_data_r0 <= PRIM_ALIGN[31:0];
						end
						else begin
							tx_data_r0 <= PRIM_WTRM[31:0];
						end
					end
			  end
			  SENDFIS_SYNC: begin
			         // sometimes device send PRIM_X_RDY after send prim_r_ok to start transition straight aways.
					if (prim_sync_det) begin
						currState <= LINK_IDLE;
						tx_data_r0 <= PRIM_SYNC[31:0];
						tx_charisk_r0 <= 1'b1;
					end
					else begin
						currState <= SENDFIS_SYNC;
						tx_data_r0 <= PRIM_SYNC[31:0];
                        tx_charisk_r0 <= 1'b1;
						if (align_insert)
							align_countdown <= 2;
						if (align_countdown != 0) begin
							align_countdown <= align_countdown - 1;
							tx_data_r0 <= PRIM_ALIGN[31:0];
						end
						else begin
							tx_data_r0 <= PRIM_SYNC[31:0];
						end
					end
			  end
			  SENDFIS_SYNC_ERR: begin
					if (prim_sync_det) begin
						currState <= LINK_IDLE;
						tx_data_r0 <= PRIM_SYNC;
						tx_charisk_r0 <= 1'b1;
					end
					else begin
						currState <= SENDFIS_SYNC_ERR;
						tx_charisk_r0 <= 1'b1;
						if (align_insert)
							align_countdown <= 2;
						if (align_countdown != 0) begin
							align_countdown <= align_countdown - 1;
							tx_data_r0 <= PRIM_ALIGN[31:0];
						end
						else begin
							tx_data_r0 <= PRIM_SYNC[31:0];
						end
					end
			  end
			  SENDFIS_PAYLOAD_HOLDA: begin
					if (prim_cont_det) begin
						currState <= SENDFIS_WAIT_HOLD;
						tx_data_r0 <= PRIM_HOLDA[31:0];
						tx_charisk_r0 <= 1'b1;
					end
					else if (prim_sync_det) begin
                       	currState <= LINK_IDLE;
                        tx_data_r0 <= PRIM_SYNC;
                        tx_charisk_r0 <= 1'b1;
                    end
					else if (prim_hold_det | prim_align_det) begin
						currState <= SENDFIS_PAYLOAD_HOLDA;
						if (align_insert)
							align_countdown <= 2;
						if (align_countdown != 0) begin
							align_countdown <= align_countdown - 1;
							tx_data_r0 <= PRIM_ALIGN[31:0];
						end
						else begin
							tx_data_r0 <= PRIM_HOLDA[31:0];
						end
					end
					else begin
                    		currState <= SENDFIS_PAYLOAD;
                    		tx_data_r0 <= to_link_data;
                    		tx_charisk_r0 <= 1'b0;
                    		tx_crcEn_r0 <= 1'b1;
                    		from_link_next_r0 <= 1'b1;
                    		align_countdown <= 0;
                    end
			  end
			  SENDFIS_WAIT_HOLD: begin
					/*if (prim_det_r1 & ~prim_align_det & ~prim_cont_det & (rx_datain != PRIM_HOLD) & (rx_datain != PRIM_CONT)) begin
						currState <= SENDFIS_PAYLOAD;
						tx_data_r0 <= to_link_data;
						tx_charisk_r0 <= 1'b0;
						tx_crcEn_r0 <= 1'b1;
						from_link_next_r0 <= 1'b1;
						align_countdown <= 0;
					end
					else */
					if (prim_sync_det) begin
					   	 currState <= LINK_IDLE;
                         tx_data_r0 <= PRIM_SYNC[31:0];
                         tx_charisk_r0 <= 1'b1;
                         from_link_next_r0 <= 1'b0;
					end
					else if ((prim_hold_det & ((rx_datain == PRIM_HOLD) | (rx_datain == PRIM_CONT))) | (prim_align_det)) begin
					   from_link_next_r0 <= 1'b1;
						currState <= SENDFIS_WAIT_HOLD;
						if (align_insert)
							align_countdown <= 2;
						if (align_countdown != 0) begin
							align_countdown <= align_countdown - 1;
							tx_data_r0 <= PRIM_ALIGN[31:0];
						end
						else begin
							tx_data_r0 <= PRIM_HOLDA[31:0];
						end
					end
					else begin
					   	currState <= SENDFIS_PAYLOAD;
                        tx_data_r0 <= to_link_data;
                        tx_charisk_r0 <= 1'b0;
                        tx_crcEn_r0 <= 1'b1;
                        from_link_next_r0 <= 1'b1;
                        align_countdown <= 0;
					end
			  end
			  default: begin
					currState <= HOST_COMRESET;
					count_en <= 1'b0;
					rx_start <= 1'b1;
					tx_elecidle_r0 <= 1'b1;
					tx_data_r0 <= PRIM_ALIGN[31:0];
					tx_charisk_r0 <= 1'b1;
			  end
         endcase
		end
   end
			
	// This counter is used for the OOB signaling
   always@(posedge clk) begin
      if (reset) begin
         count <= 18'b0;
      end
      else begin
         if(count_en) begin  
            count <= count + 1;
         end
         else begin
            count <= 18'b0;
         end
      end
   end

	/* ------------------------------------------------------------ */
   /* ChipScope Debugging                                          */
   /* ------------------------------------------------------------ */
/* 
   reg [127:0] data;
   reg [15:0]  trig0;
   wire [35:0] control;
	
	reg[5:0] 	currState_r;
	reg 			prim_det_r;
	reg[31:0] 	rx_datain_r;
	reg 			rx_charisk_r;
	reg 			rx_datain_r4_valid_r;
		
	reg[31:0]	tx_data_r;
	reg			tx_charisk_r;
		
	reg			scramblerReset_r;
	reg			scramblerEn_r;
	reg			scramblerNoPause_r;
		
	reg			crcReset_r;
	reg			crcEn_r;
		
	reg			rx_crcMatch_r0_r;
		
	reg			to_link_FIS_rdy_r1_r;
	reg			from_link_initialized_r;
	reg			from_link_idle_r;
	reg			from_link_done_r;
	reg			from_link_err_r;
	reg			rx_start_r;
	reg			rx_byteisaligned_r;
	reg			tx_elecidle_r;
	reg[17:0]	count_r;
	reg			tx_cominit_r;
	reg			tx_comwake_r;
	reg			rx_elecidle_r;
	reg			rx_cominit_det_r;
	reg			rx_comwake_det_r;
	reg			prim_sync_det_r;
		
	reg         prim_sof_det_r;
	reg			prim_eof_det_r;
	reg			prim_r_rdy_det_r;
	
	reg			prim_sync_det_rx;
	reg			prim_align_det_r;
	reg			rx_reset_done_r, tx_reset_done_r;
	
	always @(posedge clk) begin
	
	currState_r <= currState[5:0];
	prim_det_r <= prim_det_r1;
	rx_datain_r <= rx_datain;
	rx_charisk_r <= rx_charisk;
	rx_datain_r4_valid_r <= rx_datain_r4_valid;
		
	tx_data_r <= tx_data;
	tx_charisk_r <= tx_charisk;
		
	scramblerReset_r <= scramblerReset;
	scramblerEn_r <= scramblerEn;
	scramblerNoPause_r <= scramblerNoPause;
		
	crcReset_r <= crcReset;
	crcEn_r <= crcEn;
		
	rx_crcMatch_r0_r <= rx_crcMatch_r0;
		
	to_link_FIS_rdy_r1_r <= to_link_FIS_rdy_r1;
	
	from_link_initialized_r <= from_link_initialized;
	from_link_idle_r <= from_link_idle;
	from_link_done_r <= from_link_done;
	from_link_err_r <= from_link_err;
	rx_start_r <= rx_start;
	rx_byteisaligned_r <= rx_byteisaligned;
	tx_elecidle_r <= tx_elecidle;
	count_r <= count;
	tx_cominit_r <= tx_cominit;
	tx_comwake_r <= tx_comwake;
	rx_elecidle_r <= rx_elecidle;
	rx_cominit_det_r <= rx_cominit_det;
	rx_comwake_det_r <= rx_comwake_det;
	prim_sync_det_rx <= prim_sync_det;
		
	prim_sof_det_r <= prim_sof_det;
	prim_eof_det_r <= prim_eof_det;
	prim_r_rdy_det_r <= prim_r_rdy_det;
	prim_align_det_r <= prim_align_det;
	rx_byteisaligned_r <= rx_byteisaligned;
	
	rx_reset_done_r <= rx_reset_done;
	tx_reset_done_r <= tx_reset_done;
	
	end

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
		
	always @(posedge clk) begin
		data[5:0] <= currState[5:0];
		data[37:6] <= rx_datain_r4; //tx_data_r0; //rx_datain_r;
		data[38] <= tx_charisk_r0; //rx_charisk_r;
		data[39] <= rx_charisk_r; //tx_charisk_r3; //rx_datain_r4_valid; //rx_datain_r4_valid_r;
		
		data[71:40] <= rx_datain_r1; //rx_datain_r4;//rx_datain_r; //tx_data_r3; //rx_datain_r4; //tx_data_r;
		data[72] <= prim_det_r1; //tx_charisk_r0;
		data[104:73] <= to_link_data; //crcCode;
		data[105] <= rx_datain_r4_valid;
		data[106] <= from_link_next;
		data[107] <= align_insert;
		data[110:108] <= align_countdown;
		data[111] <= to_link_send_underrun;
		data[112] <= to_link_FIS_rdy_r1;
		
		trig0[5:0] <= currState_r[5:0];
		trig0[6] <= prim_sof_det_r;
		trig0[7] <= prim_det_r1;
		trig0[8] <= prim_r_rdy_det_r;
		trig0[9] <= prim_x_rdy_det_r;
		trig0[10] <= prim_sync_det_rx;
		trig0[11] <= prim_align_det_r;
		trig0[12] <= rx_start_r;
		trig0[13] <= rx_byteisaligned_r;
		trig0[14] <= tx_reset_done;
		trig0[15] <= rx_reset_done;
	end*/

endmodule
