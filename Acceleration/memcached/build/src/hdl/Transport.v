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
 * Author        : Louis Woods <louis.woods@inf.ethz.ch>, ported to VC709 by Lisa
 * Module        : Transport
 * Created       : April 20 2011
 * Last Update   : March 15 2012
 * ---------------------------------------------------------------------------
 * Description   : Command & Transport Layer
 *                 Because we implement only 4 commands we merged the Command layer and
 *                 the Transport layer into one module. The following commands are supported
 *       
 *                 (1) Read DMA Extended  (cmd == 2'b00) (SATA code = 8'h25)
 *                 (2) Write DMA Extended  (cmd == 2'b01) (SATA code = 8'h35)
 *                 (3) First Party DMA Read (cmd == 2'b10) (SATA code = 8'h60)
 *                 (4) First Party DMA Write (cmd == 2'b11) (SATA code = 8'h61)
 *       
 *                 If the linklayer module reports an error during FIS transmission, the FIS is
 *                 retransmitted if possible, i.e., if it was not a Data FIS. If it was a Data FIS the
 *                 error is reported to the application via the 'transport_err' port. Also, the
 *                 STATUS field of Register FISes coming back is checked for erros. In the case of an
 *                 error the same 'transport_err' port is used to report the error.
 * ------------------------------------------------------------------------- */

module Transport 
  (
   input             clk,
   input             reset,

   // HBA main interface: input ports
   input [2:0]       cmd,
   input             cmd_en,
   input [47:0]      lba,
   input [15:0]      sectorcnt,
   input [31:0]      wdata,
   input             wdata_en,
   input             rdata_next, 

   // HBA main interface: output ports
   output            wdata_full,
   output [31:0]     rdata,
   output            rdata_empty,
   output reg        cmd_failed,
   output reg        cmd_success,

   // HBA NCQ extension
   input [4:0]       ncq_wtag,
   output reg [4:0]  ncq_rtag,
   output reg        ncq_idle,
   output reg        ncq_relinquish,
   output reg        ncq_ready_for_wdata,
   output reg [31:0] ncq_SActive, // SActive register tells application which commands completed, every bit corresponds to a tag
   output reg        ncq_SActive_valid,
   
   // Link module interface: input ports
   input             from_link_idle,
   input             from_link_ready_to_transmit,
   input             from_link_next,
   input [31:0]      from_link_data,
   input             from_link_data_en,
   input             from_link_done, // Link module has completed transmission of a FIS
   input             from_link_err, // CRC32-error when receiving FIS, R_ERR primitive when transmitting FIS
   
   // Link module interface: output ports
   output reg        to_link_FIS_rdy, // tell Link module that we want to send a FIS (command)
   output [31:0]     to_link_data,
   output reg        to_link_done,
   output            to_link_receive_overflow,
   output            to_link_send_empty,
   output            to_link_send_underrun,
   
   //debug signals
   output[6:0] state_de,
   
   output [4:0]         current_sectorcnt_de,
   output wordcnt_en_de,
   output wordcnt_clear_de,
   output [7:0]         wordcnt_de
   );
   
   reg [47:0]        REGISTER_FIS_LBA;
   reg [15:0]        REGISTER_FIS_SECTORCNT;
   reg [4:0]         TAG;

   // a data FIS has a max size of 8192 bytes -> 16 sectors
   reg [4:0]         current_sectorcnt;
   
   // a sector has 512 bytes -> 256 words
   wire              wordcnt_en;
   reg               wordcnt_clear;
   reg [7:0]         wordcnt;
   
   reg [31:0]        from_link_data_r1;
   reg [31:0]        from_link_data_r2;
   reg [31:0]        from_link_data_r3;
   
   reg               from_link_data_en_r1;
   reg               from_link_data_en_r2;
   reg               from_link_data_en_r3;
   
   // Errors
   reg               unrecoverable_error;

   // data to buffer-out (sending data to device -> going to Link module)
   reg [31:0]        buffer_out_wdata;
   reg               buffer_out_wdata_en;
   wire              buffer_out_full;
   wire              buffer_out_empty;
   wire              buffer_out_underrun;
   wire              buffer_out_overflow;

   // after reset the drive first sends a device signature (Register FIS)
   reg               signature_read;
   
   // Commands implemented in the transport module
   localparam [2:0] 
     CMD_IDENTIFY_DEVICE           = 3'b000,
     CMD_READ_DMA_EXTENDED         = 3'b001,
     CMD_WRITE_DMA_EXTENDED        = 3'b010,
     CMD_FIRST_PARTY_DMA_READ_NCQ  = 3'b011,
     CMD_FIRST_PARTY_DMA_WRITE_NCQ = 3'b100;
   
   //FSM states
   localparam 
     IDLE                                = 0,

     // Read device signature
     DEVICE_SIGNATURE                    = 1,

     // Identify Device (0xEC)
     IDENTIFY_DEVICE_IDLE_0              = 2,
     IDENTIFY_DEVICE_WAIT_RRDY_0         = 3,
     IDENTIFY_DEVICE_DW0               = 4,
     IDENTIFY_DEVICE_DW1               = 5,
     IDENTIFY_DEVICE_DW2               = 6,
     IDENTIFY_DEVICE_DW3               = 7,
     IDENTIFY_DEVICE_DW4               = 8,
     IDENTIFY_DEVICE_SENDCMD             = 9,
     IDENTIFY_DEVICE_WAITACK1            = 10,
     IDENTIFY_DEVICE_PIO_SETUP_FIS_DW0 = 11,
     IDENTIFY_DEVICE_PIO_SETUP_DWI       = 12,
     IDENTIFY_DEVICE_DATAFIS_DW0       = 13,
     IDENTIFY_DEVICE_DATAFIS_DWI         = 14,
   
     // Read DMA Extended (0x25) 
     DMA_READ_WAIT_IDLE_0                = 15,
     DMA_READ_WAIT_RRDY_0                = 16,
     DMA_READ_DW0                      = 17,
     DMA_READ_DW1                      = 18,
     DMA_READ_DW2                      = 19,
     DMA_READ_DW3                      = 20,
     DMA_READ_DW4                      = 21,
     DMA_READ_SENDCMD                    = 22,
     DMA_READ_WAITACK1                   = 23,
     DMA_READ_DATAFIS_DW0              = 24,
     DMA_READ_DATAFIS_DWI                = 25,
     DMA_READ_NEXTFIS_DW0              = 26,
     DMA_READ_WAITACK3                   = 27,
   
     // Write DMA Extended (0x35)
     DMA_WRITE_WAIT_IDLE_0               = 28,
     DMA_WRITE_WAIT_RRDY_0               = 29,
     DMA_WRITE_DW0                     = 30,
     DMA_WRITE_DW1                     = 31,
     DMA_WRITE_DW2                     = 32,
     DMA_WRITE_DW3                     = 33,
     DMA_WRITE_DW4                     = 34,
     //DMA_WRITE_DW4_U                     = 53,
     DMA_WRITE_SENDCMD                   = 35,
     DMA_WRITE_WAITACK1                  = 36,
     DMA_WRITE_WAITACK2                  = 37,
	  //DMA_WRITE_WAITACK2_1                =53,
     DMA_WRITE_WAIT_IDLE_1               = 38,
     DMA_WRITE_WAIT_RRDY_1               = 39,
     DMA_WRITE_DATA_DW0                = 40,
     
     DMA_WRITE_WAIT_USER_DATA            = 41,
     DMA_WRITE_DATA_USER_0               = 42,
     DMA_WRITE_DATA_USER_1               = 43,
     DMA_WRITE_WAITACK3                  = 44,
     DMA_WRITE_NEXTFIS_DW0             = 45,
     
     DMA_WRITE_WAITACK4                  = 46,
     DMA_WRITE_WAITDMAACTIVATE           = 47,

     // NCQ: First Party DMA Read (0x60)
     NCQ_READ_WAIT_IDLE_0                = 48,
     NCQ_READ_WAIT_RRDY_0                = 49,
     NCQ_READ_DW0                      = 50,
     NCQ_READ_DW1                      = 51,
     NCQ_READ_DW2                      = 52,
     NCQ_READ_DW3                      = 53,
     
     NCQ_READ_DW4                      = 54,
     NCQ_READ_SENDCMD                    = 55,
     NCQ_READ_WAITACK_1                  = 56,
     NCQ_READ_REGISTERFIS_DW0          = 57,
     NCQ_READ_WAITACK_2                  = 58,
     NCQ_READ_DATAFIS_DWI                = 59,
     
     // NCQ: First Party DMA Write (0x61)
     NCQ_WRITE_WAIT_IDLE_0               = 60,
     NCQ_WRITE_WAIT_RRDY_0               = 61,
     NCQ_WRITE_DW0                     = 62,
     NCQ_WRITE_DW1                     = 63,
     NCQ_WRITE_DW2                     = 64,
     NCQ_WRITE_DW3                     = 65,
     NCQ_WRITE_DW4                     = 66,
     NCQ_WRITE_SENDCMD                   = 67,
     NCQ_WRITE_WAITACK_1                 = 68,
     NCQ_WRITE_REGISTERFIS_DW0         = 69,
     NCQ_WRITE_WAITACK_2                 = 70,
     NCQ_WRITE_WAIT_IDLE_1               = 71,
     NCQ_WRITE_WAIT_RRDY_1               = 72,
     NCQ_WRITE_DATA_DW0                = 73,
     NCQ_WRITE_WAIT_USER_DATA            = 74,
     NCQ_WRITE_DATA_USER_0               = 75,
     NCQ_WRITE_DATA_USER_1               = 76,
     NCQ_WRITE_WAITACK3                  = 77,
   
     // NCQ : Asynchronous receive DMA Setup FIS
     
     NCQ_DMASETUPFIS_DW1               = 78,
     NCQ_WAITACK_1                       = 79,
     NCQ_DATAFIS_DW0                   = 80,

     // NCQ : Asynchronous receive SetDevBits FIS  
     NCQ_SETDEVBITSFIS_DW1             = 81,
     NCQ_WAITACK_2                       = 82;

    //parameter for debuggin
    localparam[31:0] LATENCY = 32'd65536;//32'd32768; //32'd65536;
   // state register
   reg [6:0]         currState;

   // in some cases the HBA buffer is not ready to accept writes
   // -> we then tell the application that the buffer is full (wdata_full)
   reg               block_outbuf_writes;
   
   // in some cases we don't want the Link module to start reading from the buffer
   // in those cases we tell the link  module the buffer is still empty (to_link_send_empty)
   reg               block_outbuf_reads;
   reg [15:0]        ncq_sector_cnt;
	
	//Lisa: statistic circuit
	reg [31:0] latency_r;
	reg [23:0] cmdTransTime_r;
	reg [23:0] dataRecTime_r;
	reg clear_buffer_r;

   assign state_de = currState;
   assign current_sectorcnt_de = current_sectorcnt;
   assign wordcnt_en_de = wordcnt_en;
   assign wordcnt_clear_de = wordcnt_clear;
   assign wordcnt_de = wordcnt;
   
   assign wdata_full            = (block_outbuf_writes || buffer_out_overflow || (current_sectorcnt[3:0] == REGISTER_FIS_SECTORCNT[3:0])); //(currState == DMA_WRITE_DATA_USER_0)? (block_outbuf_writes || buffer_out_overflow || (current_sectorcnt[3:0] == REGISTER_FIS_SECTORCNT[3:0])):
                                  //(block_outbuf_writes || buffer_out_overflow);  
   assign to_link_send_empty    = block_outbuf_reads  || buffer_out_empty;
   assign to_link_send_underrun = block_outbuf_reads  || buffer_out_underrun;
   assign wordcnt_en            = (!buffer_out_full) && buffer_out_wdata_en;
   
   always @(posedge clk) begin
      if(reset) begin
			latency_r <= 0;
			cmdTransTime_r <= 0;
			dataRecTime_r <= 0;
         currState           <= IDLE;

         signature_read      <= 0;
         unrecoverable_error <= 0;
         block_outbuf_writes <= 1;
         block_outbuf_reads  <= 0;
         cmd_failed          <= 0;
         cmd_success         <= 0;
         buffer_out_wdata_en <= 0;
         to_link_FIS_rdy     <= 0;
         to_link_done        <= 0;
         
         wordcnt_clear        <= 0;
         
         from_link_data_r1   <= 32'b0; 
         from_link_data_r2   <= 32'b0; 
         from_link_data_r3   <= 32'b0; 
         
         from_link_data_en_r1 <= 0;
         from_link_data_en_r2 <= 0;
         from_link_data_en_r3 <= 0;

         ncq_idle            <= 0;
         ncq_relinquish      <= 0;
         ncq_ready_for_wdata <= 0;
         ncq_SActive         <= 0;
         ncq_SActive_valid   <= 0;
         clear_buffer_r <= 1'b0;
      end
      else begin
         
         from_link_data_en_r3 <= 0;
         block_outbuf_writes  <= 1;
         block_outbuf_reads   <= 0;
         
         ncq_idle          <= 0;
         ncq_relinquish    <= 0;
         ncq_SActive_valid <= 0;
         
         case(currState)
           IDLE: begin // 0
              unrecoverable_error <= 0;
              cmd_failed          <= 0;
              cmd_success         <= 0;
              buffer_out_wdata_en <= 0;
              to_link_done        <= 0;
              ncq_idle            <= 1;

              if(from_link_data_en) begin

                 // --- Device Signature ---------------------------------------------------
                 // --- Desc : after device reset the device executes internal diagnostics
                 // ---        and sends a register FIS containing (1) device signature
                 // ---        (2) diagnostic results. No primitive-based handshaking is
                 // ---        performed, which is why we need to catch this data here in
                 // ---        IDLE state if we want to return it to the application.
                 
                 if(!signature_read) begin
                   currState <= DEVICE_SIGNATURE;
						 from_link_data_en_r1 <= from_link_data_en;
						 from_link_data_r1 <= from_link_data;
                 end

                 // --- Asynchronous I/O ---------------------------------------------------
                 // --- Desc : with native command queueing (I/O) the drive may execute
                 // ---        commands out-of-order, i.e., we always have to expect that
                 // ---        the drive will respond with FISes to some command that was
                 // --         issued previously
                 
                 else begin

                    // Read DW0[15:0]
                    if(from_link_data_en) begin

                       ncq_relinquish <= 1;
                       
                       // Drive sends DMA Setup FIS
                       if(from_link_data[7:0] == 16'h41) begin
                          // from_link_data[7:0]  = FIS type (16'h41 = DMA Setup FIS)
                          // from_link_data[15:8] = A|I|D|Reserved[4:0]
                          
                          // auto activate option was used
                          if(from_link_data[15] == 1'b1) begin
                             // some drives might combine DMA setup and DMA Activate FIS
                             ncq_ready_for_wdata <= 1;
									  if(from_link_done) begin
											currState <= NCQ_WRITE_WAIT_IDLE_1;
									  end
                          end
                          // auto activate option not used
                          else begin
                              // all drives we tested do not make use of auto activate
                             // from_link_data[7:0]  = Reserved
									  // from_link_data[15:8] = Reserved
										currState <= NCQ_DMASETUPFIS_DW1;
                          end
                       end

                       // Drive sends additional Data FIS
                       else if(from_link_data[7:0] == 16'h46) begin
                          // if read request did not fit into one Data FIS -> read next Data FIS
									from_link_data_en_r1 <= 0;
									from_link_data_en_r2 <= 0;
									currState            <= NCQ_READ_DATAFIS_DWI;
                       end

                       // Drive sends additional DMA Activate FIS
                       else if(from_link_data[7:0] == 16'h39) begin
                          // FIS type == DMA Activate -> send more data
                          ncq_ready_for_wdata <= 1;
								  if(from_link_done) begin
										currState <= NCQ_WRITE_WAIT_IDLE_1;
								  end
                       end
                       
                       // Drive sends Set Device Bits FIS
                       else if(from_link_data[7:0] == 16'hA1) begin
                          // from_link_data[7:0]  = FIS type (16'hA1 = Set Device Bits FIS)
                          // from_link_data[15:8] = R|I|D|Reserved[4:0]
                          // from_link_data[2:0]  = Status Low
								// from_link_data[18]    = R
								// from_link_data[21:19]  = Status High
								// from_link_data[22]    = R
								// from_link_data[31:23] = Error
									currState <= NCQ_SETDEVBITSFIS_DW1;
                       end

                    end
                    
                 end
                 
                 from_link_data_en_r1 <= from_link_data_en;   
                 from_link_data_r1    <= from_link_data;
              end
              else begin
                 from_link_data_en_r1 <= 0;
                 from_link_data_en_r2 <= 0;
                 from_link_data_en_r3 <= 0;
              end

              // --- Host (FPGA) initiates command --------------------------------------
              if(cmd_en) begin
                 
                 REGISTER_FIS_LBA       <= lba;
                 REGISTER_FIS_SECTORCNT <= sectorcnt;
                 TAG                    <= ncq_wtag;
                 ncq_sector_cnt         <= sectorcnt;
                 
                 // cmd = Identify Device (0xEC)
                 if(cmd == CMD_IDENTIFY_DEVICE) begin
                    currState <= IDENTIFY_DEVICE_IDLE_0;
                 end
                 // cmd = Read DMA Extended (0x25)
                 else if(cmd == CMD_READ_DMA_EXTENDED) begin
                    currState <= DMA_READ_WAIT_IDLE_0;
                 end
                 // cmd = Write DMA Extended (0x35)
                 else if(cmd == CMD_WRITE_DMA_EXTENDED) begin
                    currState <= DMA_WRITE_WAIT_IDLE_0;
                 end
                 // cmd = First Party DMA Read (0x60)
                 else if(cmd == CMD_FIRST_PARTY_DMA_READ_NCQ) begin
                    currState <= NCQ_READ_WAIT_IDLE_0;
                 end
                 // cmd = First Party DMA Write (0x61)
                 else if(cmd == CMD_FIRST_PARTY_DMA_WRITE_NCQ) begin
                    currState <= NCQ_WRITE_WAIT_IDLE_0;
                 end
                 
              end
           end

           /* ------------------------------------------------------------ */
           /* Read Device Signature                                        */
           /* ------------------------------------------------------------ */
           
           DEVICE_SIGNATURE: begin
              signature_read <= 1;
                        
              from_link_data_en_r1 <= from_link_data_en;
              from_link_data_en_r2 <= from_link_data_en_r1;
              from_link_data_en_r3 <= from_link_data_en_r2 & from_link_data_en_r1; //Lisa: don't store CRC      
                 
              from_link_data_r1 <= from_link_data;
              from_link_data_r2 <= from_link_data_r1;
              from_link_data_r3 <= from_link_data_r2;

              if(from_link_done) begin
                 currState <= IDLE;
              end
              
           end
   
           /* ------------------------------------------------------------ */
           /* Identify Device (PIO Data-In Command)                        */
           /* ------------------------------------------------------------ */

           // --- Wait for link to become ready --------------------------
           
           IDENTIFY_DEVICE_IDLE_0: begin     
              if(from_link_idle) begin
                 to_link_FIS_rdy <= 1;
                 currState       <= IDENTIFY_DEVICE_WAIT_RRDY_0;
              end
           end
           
           IDENTIFY_DEVICE_WAIT_RRDY_0: begin
              to_link_FIS_rdy <= 0;
              currState       <= IDENTIFY_DEVICE_DW0;
           end

           // --- Send Register FIS --------------------------------------
 
			  IDENTIFY_DEVICE_DW0: begin
              // DW0[7:0]  = FIS type: 0x27 (Host to Device Register FIS)
              // DW0[15:8] = C|R|R|Reserved[4:0], C = 0 -> control register, C = 1 -> command register
				  // DW0[23:16] = Command = 0xEC -> Identify Device
              // DW0[31:24] = Features
              buffer_out_wdata <= 32'h00EC8027; //16'h8027;
              if(!buffer_out_full) begin
                 buffer_out_wdata_en <= 1;
                 currState           <= IDENTIFY_DEVICE_DW1;
              end
           end
 
           IDENTIFY_DEVICE_DW1: begin
					// DW1[31:28] = Device
              if(!buffer_out_full) begin
                 buffer_out_wdata <= 32'hE0000000; //16'h0000;
                 currState        <= IDENTIFY_DEVICE_DW2;
              end
           end
			  
           IDENTIFY_DEVICE_DW2: begin
              if(!buffer_out_full) begin
                 buffer_out_wdata <= 32'h00000000;
                 currState        <= IDENTIFY_DEVICE_DW3;
              end
           end
           
           IDENTIFY_DEVICE_DW3: begin
              if(!buffer_out_full) begin
                 buffer_out_wdata <= 32'h00000000;
                 currState        <= IDENTIFY_DEVICE_DW4;
              end
           end
           
           IDENTIFY_DEVICE_DW4: begin
              if(!buffer_out_full) begin
                 buffer_out_wdata <= 32'h00000000;
                 currState        <= IDENTIFY_DEVICE_SENDCMD;
              end
           end
           
           
           IDENTIFY_DEVICE_SENDCMD: begin
              buffer_out_wdata_en <= 0;
              to_link_done        <= 1;
              currState           <= IDENTIFY_DEVICE_WAITACK1;
           end
           
           IDENTIFY_DEVICE_WAITACK1: begin
              if(from_link_done) begin
                 to_link_done <= 0;
                 // there was an error receiving the command -> retry
                 if(from_link_err) begin
                    if (~buffer_out_empty) begin
                        clear_buffer_r <= 1'b1;
                    end
                    else begin
                        clear_buffer_r <= 1'b0;
                        currState <= IDENTIFY_DEVICE_IDLE_0;
                    end
                 end
                 // command was successful -> receive next FIS
                 else begin
                    currState <= IDENTIFY_DEVICE_PIO_SETUP_FIS_DW0;
                 end
              end
           end
           
           // --- Receive PIO Setup FIS ----------------------------------
           IDENTIFY_DEVICE_PIO_SETUP_FIS_DW0: begin
              // Read DW0[31:0]
              if(from_link_data_en) begin
                 // from_link_data[7:0]  = FIS type
                 // from_link_data[15:8] = R|I|D|Reserved[4:0]
                 if(from_link_data[7:0] == 16'h5F) begin
                    // FIS type == PIO Setup FIS (Ox5F) -> finished
                     // from_link_data[23:16]  = STATUS (BSY|DRDY|DF/SE|#|DRQ|OBS|OBS|ERR/CHK)
							// from_link_data[31:24] = ERROR
							// Notice, ERROR is only valid if ERR (STATUS[0]) is reported in STATUS
							unrecoverable_error <= unrecoverable_error | from_link_data[16];
							currState           <= IDENTIFY_DEVICE_PIO_SETUP_DWI;
                 end
              end
              else if (from_link_done) begin 
              //if state machine is still here when from_link_done is asserted, 
              //then device did not return correct PIO setup FIS
                cmd_failed <= 1'b1;
                currState <= IDLE;
              end
           end
           
            
           IDENTIFY_DEVICE_PIO_SETUP_DWI: begin
              // Skip the remaining 4 DWs and wait until link is done
              if(from_link_done) begin
                 currState <= IDENTIFY_DEVICE_DATAFIS_DW0;
              end
           end

           // --- Receive Data FIS ---------------------------------------
           IDENTIFY_DEVICE_DATAFIS_DW0: begin
              if(from_link_data_en) begin
                 from_link_data_en_r1 <= 0;
                 from_link_data_en_r2 <= 0;
                 currState            <= IDENTIFY_DEVICE_DATAFIS_DWI;
              end
           end
           
           IDENTIFY_DEVICE_DATAFIS_DWI: begin
              // we delay output of data by 32-bit to automatically cut of the CRC at the end of the FIS
             if(from_link_data_en || from_link_data_en_r1) begin
                 from_link_data_en_r1 <= from_link_data_en;
                 from_link_data_en_r2 <= from_link_data_en_r1;
                 from_link_data_en_r3 <= from_link_data_en_r2;
                 
                 from_link_data_r1 <= from_link_data;
                 from_link_data_r2 <= from_link_data_r1;
                 from_link_data_r3 <= from_link_data_r2;
              end
             else if (~from_link_data_en_r1) begin
                 from_link_data_en_r3 <= 0;
              end
              if(from_link_done) begin
                 if(unrecoverable_error | from_link_err) begin
                    cmd_failed <= 1;
                 end
                 else begin
                    cmd_success <= 1;
                 end
                 currState <= IDLE;
              end
           end

           
           /* ------------------------------------------------------------ */
           /* Read DMA Extended (0x25)                                     */
           /* ------------------------------------------------------------ */
           
           DMA_READ_WAIT_IDLE_0: begin
              if(from_link_idle) begin
                 to_link_FIS_rdy <= 1;
                 currState       <= DMA_READ_WAIT_RRDY_0;
              end
           end
           
           DMA_READ_WAIT_RRDY_0: begin
              to_link_FIS_rdy <= 0;
              currState       <= DMA_READ_DW0;
           end
           
           DMA_READ_DW0: begin
              // DW0[7:0]  = FIS type: 0x27 (Host to Device Register FIS)
              // DW0[15:8] = C|R|R|Reserved[4:0], C = 0 -> control register, C = 1 -> command register
				    // DW0[23:16] = Command = 0x25 -> Read DMA Extended (Max. REGISTER_FIS_SECTORCNT = 65535, => 32 MiB)
              //              Command = 0xC8 -> Read DMA (Max. REGISTER_FIS_SECTORCNT = 255, => 128 KiB)
              // DW0[31:24] = Features
              //buffer_out_wdata <= 16'h8027;
              if(!buffer_out_full) begin
                 buffer_out_wdata_en <= 1;
					  buffer_out_wdata <= 32'h00258027;
                 currState        <= DMA_READ_DW1;
              end
           end
           
           DMA_READ_DW1: begin
              // DW1[7:0]  = Sector Number -> REGISTER_FIS_LBA[7:0]
              // DW1[15:8] = Cyl Low       -> REGISTER_FIS_LBA[15:8]
				  // DW1[23:16] = Cyl High -> REGISTER_FIS_LBA[23:16]
              // DW1[31:24] = Dev/Head -> bit 4 : device number used to select drive 0,1, bits[3:0] head number with legacy addressing (Cylinder, Head, Sector)
              if(!buffer_out_full) begin
                 buffer_out_wdata[15:0] <= REGISTER_FIS_LBA[15:0];
                 buffer_out_wdata[31:16] <= {8'hE0,REGISTER_FIS_LBA[23:16]};
                 currState        <= DMA_READ_DW2;
              end
           end
           
			  DMA_READ_DW2: begin
              // DW2[7:0]  = Sector Number (exp) -> REGISTER_FIS_LBA[31:24]
              // DW2[15:8] = Cyl Low (exp)       -> REGISTER_FIS_LBA[39:32]
				  // DW2[23:16] = Cyl High (exp) -> REGISTER_FIS_LBA[47:40]
              // DW2[31:24] = Reserved
              if(!buffer_out_full) begin
                 buffer_out_wdata[15:0] <= REGISTER_FIS_LBA[39:24];
                 buffer_out_wdata[31:16] <= {8'h00,REGISTER_FIS_LBA[47:40]};
                 currState        <= DMA_READ_DW3;
              end
           end
           
           DMA_READ_DW3: begin
              // DW3[7:0]  = Sector Count
              // DW3[15:8] = Sector Count (Exp)
				  // DW3[23:16] = Reserved
              // DW3[31:24] = Reserved
              if(!buffer_out_full) begin
                 buffer_out_wdata[15:0] <= REGISTER_FIS_SECTORCNT;
                 buffer_out_wdata[31:16] <= 16'h0000;
                 currState        <= DMA_READ_DW4;
              end
           end
           
           DMA_READ_DW4: begin
              // DW4[7:0]  = Reserved
              // DW4[15:8] = Reserved
				  // DW4[23:16] = Reserved
              // DW4[31:24] = Reserved
              if(!buffer_out_full) begin
                 buffer_out_wdata[15:0] <= 16'h0000;
                  buffer_out_wdata[31:16] <= 16'h0000;
                 currState        <= DMA_READ_SENDCMD;
              end
           end

           DMA_READ_SENDCMD: begin
              buffer_out_wdata_en <= 0;
              to_link_done        <= 1;
              currState           <= DMA_READ_WAITACK1;
			  cmdTransTime_r <= 0;
           end
           
           DMA_READ_WAITACK1: begin
			  cmdTransTime_r <= cmdTransTime_r + 1;
              if(from_link_done) begin
                   to_link_done <= 0;
                   // there was an error receiving the command -> retry
                   if(from_link_err) begin
                      currState <= DMA_READ_WAIT_IDLE_0;
                   end
                   // command was successful -> receive next FIS
                   else begin
                      currState <= DMA_READ_DATAFIS_DW0;
                   end
                end
              else if (from_link_err) begin
                to_link_FIS_rdy <= 1'b1; //meet error before starting to send FIS
              end
              else if (~from_link_idle) begin
                to_link_FIS_rdy <= 1'b0;
              end
           end
           
           DMA_READ_DATAFIS_DW0: begin
                  if (latency_r == LATENCY) begin //32'd65536) begin
                    latency_r <= latency_r;
                  end
                  else begin
				    latency_r <= latency_r + 1;
				  end
				  // there was an error receiving the command -> retry
		      if (from_link_data_en & (from_link_data[7:0] == 16'h34)) begin
                  if (~buffer_out_empty) begin
                          clear_buffer_r <= 1'b1;
                  end
                  else begin
                      clear_buffer_r <= 1'b0;
                      currState <= DMA_READ_WAIT_IDLE_0;
                  end
		      end
              else if(from_link_data_en) begin
                 from_link_data_en_r1 <= 0;
                 from_link_data_en_r2 <= 0;
                 currState            <= DMA_READ_DATAFIS_DWI;
					  //dataRecTime_r <= 0;
              end             
           end
           
           DMA_READ_DATAFIS_DWI: begin
					//dataRecTime_r <= dataRecTime_r + 1;
              // we delay output of data by 32-bit to automatically cut of the CRC at the end of the FIS
             if(from_link_data_en || from_link_data_en_r1) begin
                 from_link_data_en_r1 <= from_link_data_en;
                 from_link_data_en_r2 <= from_link_data_en_r1;
                 from_link_data_en_r3 <= from_link_data_en_r2; 
                 
                 from_link_data_r1 <= from_link_data;
                 from_link_data_r2 <= from_link_data_r1;
                 from_link_data_r3 <= from_link_data_r2;
              end
              else if (~from_link_data_en_r1) begin
                from_link_data_en_r3 <= 0;
              end
              if(from_link_done) begin
                    unrecoverable_error <= unrecoverable_error | from_link_err;
                    currState           <= DMA_READ_NEXTFIS_DW0;
                    dataRecTime_r <= 0;
              end
           end
           
           DMA_READ_NEXTFIS_DW0: begin
              dataRecTime_r <= dataRecTime_r + 1;
              if(from_link_data_en) begin
                 // from_link_data[7:0] = FIS type
                 // from_link_data[15:8] = C|R|R|Reserved[4:0], C = 0 -> control register, C = 1 -> command register
                 if(from_link_data[7:0] == 16'h34) begin
                    // FIS type == REGISTER FIS -> finished
						  // from_link_data[23:16]  = STATUS
                 // from_link_data[31:24] = ERROR
                 // Notice, ERROR is only valid if ERR (STATUS[0]) is reported in STATUS
                   unrecoverable_error <= unrecoverable_error | from_link_data[16];
						 currState           <= DMA_READ_WAITACK3;
                 end
                 else if(from_link_data[7:0] == 16'h46) begin
                    // FIS type == DATA FIS -> receive more data
                    currState <= DMA_READ_DATAFIS_DW0;
                 end
              end
              else if (dataRecTime_r == 4096) begin
                    currState           <= IDLE;
              end
           end
           
           DMA_READ_WAITACK3: begin
              if(from_link_done) begin
                 if(unrecoverable_error) begin
                    cmd_failed <= 1;
                 end
                 else begin
                    cmd_success <= 1;
                 end
                 currState <= IDLE;
              end
           end
           

           /* ------------------------------------------------------------ */
           /* Write DMA Extended (0x35)                                    */
           /* ------------------------------------------------------------ */

           DMA_WRITE_WAIT_IDLE_0: begin
              if(from_link_idle) begin
                 to_link_FIS_rdy <= 1;
                 currState       <= DMA_WRITE_WAIT_RRDY_0;
              end
           end
           
           DMA_WRITE_WAIT_RRDY_0: begin
              to_link_FIS_rdy <= 0;
              currState       <= DMA_WRITE_DW0;
           end
           
           DMA_WRITE_DW0: begin
              // DW0[7:0]  = FIS type: 0x27 (Host to Device Register FIS)
              // DW0[15:8] = C|R|R|Reserved[4:0], C = 0 -> control register, C = 1 -> command register
				  // DW0[23:16] = Command = 0x35 -> Write DMA Extended (Max. REGISTER_FIS_SECTORCNT = 65535, => 32 MiB)
              //              Command = 0xCA -> Write DMA (Max. REGISTER_FIS_SECTORCNT = 255, => 128 KiB)
              // DW0[31:24] = Features
              buffer_out_wdata[15:0] <= 16'h8027;
              if(!buffer_out_full) begin
                 buffer_out_wdata_en <= 1;
                 buffer_out_wdata[31:16] <= 16'h0035;
                 //buffer_out_wdata <= 16'h00CA;  // Attention : Max. Sector Count = 255
                 currState        <= DMA_WRITE_DW1;
              end
           end
           
           DMA_WRITE_DW1: begin
              // DW1[7:0]  = Sector Number -> REGISTER_FIS_LBA[7:0]
              // DW1[15:8] = Cyl Low       -> REGISTER_FIS_LBA[15:8]
              if(!buffer_out_full) begin
                 buffer_out_wdata[15:0] <= REGISTER_FIS_LBA[15:0];
                 buffer_out_wdata[31:16] <= {8'hE0,REGISTER_FIS_LBA[23:16]};
                 currState        <= DMA_WRITE_DW2;
              end
           end

           DMA_WRITE_DW2: begin
              // DW2[7:0]  = Sector Number (exp) -> REGISTER_FIS_LBA[31:24]
              // DW2[15:8] = Cyl Low (exp)       -> REGISTER_FIS_LBA[39:32]
              if(!buffer_out_full) begin
                 buffer_out_wdata[15:0] <= REGISTER_FIS_LBA[39:24];
                 buffer_out_wdata[31:16] <= {8'h00,REGISTER_FIS_LBA[47:40]};
                 currState        <= DMA_WRITE_DW3;
              end
           end

           DMA_WRITE_DW3: begin
              // DW3[7:0]  = Sector Count
              // DW3[15:8] = Sector Count (Exp)
              if(!buffer_out_full) begin
                 buffer_out_wdata[15:0] <= REGISTER_FIS_SECTORCNT;
                 buffer_out_wdata[31:16] <= 16'h0000;
                 currState        <= DMA_WRITE_DW4;
              end
           end

           DMA_WRITE_DW4: begin
              // DW4[7:0]  = Reserved
              // DW4[15:8] = Reserved
              if(!buffer_out_full) begin
                 buffer_out_wdata[15:0] <= 16'h0000;
                 buffer_out_wdata[31:16] <= 16'h0000;
                 currState        <= DMA_WRITE_SENDCMD;
              end
           end

           DMA_WRITE_SENDCMD: begin
              buffer_out_wdata_en <= 0;
              to_link_done        <= 1;
              currState           <= DMA_WRITE_WAITACK1;
           end
			  
           DMA_WRITE_WAITACK1: begin
              if(from_link_done) begin
                 to_link_done <= 0;
                 // there was an error receiving the command -> retry
                 if(from_link_err) begin
                    currState <= DMA_WRITE_WAIT_IDLE_0;
                 end
                 // command was successful -> receive next FIS
                 else begin
                    currState <= DMA_WRITE_WAITACK2;
                 end
              end
              else if (from_link_err) begin
                to_link_FIS_rdy <= 1'b1; //meet error before starting to send FIS
              end
              else  if (~from_link_idle)begin
                to_link_FIS_rdy <= 1'b0;
              end
           end

           DMA_WRITE_WAITACK2: begin
              if (from_link_data_en ) begin
                if ((from_link_data[7:0] == 8'h39)) begin
                    currState <= DMA_WRITE_WAIT_IDLE_1;
                end
                else begin
                    currState <= DMA_WRITE_WAIT_IDLE_0; //retry;
                end
              end
           end     

           DMA_WRITE_WAIT_IDLE_1: begin
              if(from_link_idle) begin
                 to_link_FIS_rdy <= 1;
                 currState       <= DMA_WRITE_WAIT_RRDY_1;
              end
           end

           DMA_WRITE_WAIT_RRDY_1: begin
              to_link_FIS_rdy <= 0;
              currState       <= DMA_WRITE_DATA_DW0;
              wordcnt_clear <= 1'b1;
           end

           DMA_WRITE_DATA_DW0: begin
              block_outbuf_reads <= 1;
              // DW0[7:0]  = FIS type: 0x46 (Data FIS)
              // DW0[15:8] = R|R|R|Reserved[4:0]
              buffer_out_wdata[15:0] <= 16'h0046;
              if(!buffer_out_full) begin
                 buffer_out_wdata_en <= 1;
                 wordcnt_clear       <= 0;
                 buffer_out_wdata[31:16] <= 16'h0000;
                 currState        <= DMA_WRITE_WAIT_USER_DATA;
              end
           end

           DMA_WRITE_WAIT_USER_DATA: begin
              // block Link module reads until user is ready
              
              block_outbuf_reads  <= 1;
              block_outbuf_writes <= 0;
              buffer_out_wdata_en <= wdata_en;
              if((!buffer_out_full) && wdata_en) begin
                 buffer_out_wdata <= wdata;
                 
                 // Maximum size of any FIS is 8 KiB
                 // Because the first DW (4 bytes) contains the FIS type (0x46) 
                 // we cannot put more than 15 sectors into a single Data FIS
                 
                 // still need more than one Data FIS to transmit data
                 if(REGISTER_FIS_SECTORCNT > 15) begin
                    currState <= DMA_WRITE_DATA_USER_1;
                 end
                 // a single FIS is sufficient
                 else begin
                    currState <= DMA_WRITE_DATA_USER_0;
                 end
                 
              end
           end
           
           DMA_WRITE_DATA_USER_0: begin
              block_outbuf_writes <= 0;
              buffer_out_wdata_en <= wdata_en;
              if((!buffer_out_full) && wdata_en) begin
                 buffer_out_wdata <= wdata;
              end
              // stop as soon as we wrote enough sectors to the buffer
              if(current_sectorcnt[3:0] == REGISTER_FIS_SECTORCNT[3:0]) begin
                 to_link_done           <= 1;
                 REGISTER_FIS_SECTORCNT <= 0;
                 buffer_out_wdata_en    <= 0;
                 currState              <= DMA_WRITE_WAITACK3;
                 block_outbuf_writes <= 1'b1;
              end
           end

           DMA_WRITE_DATA_USER_1: begin
              block_outbuf_writes <= 0;

              // Need to stop reading from buffer one cycle before current_sectorcnt will be equal to 15
              if((current_sectorcnt == 14)  && (wordcnt[7:0]==8'b10000000) && wordcnt_en) begin
                 block_outbuf_writes <= 1;
              end
              
              buffer_out_wdata_en <= wdata_en;                 
              if((!buffer_out_full) && wdata_en) begin
                 buffer_out_wdata <= wdata;
              end
              
              // Maximum size of any FIS is 8 KiB
              // Because the first DW (4 bytes) contains the FIS type (0x46) 
              // we cannot put more than 15 sectors into a single Data FIS              
              if(current_sectorcnt == 15) begin
                 block_outbuf_writes    <= 1;
                 to_link_done           <= 1;
                 buffer_out_wdata_en    <= 0;
                 REGISTER_FIS_SECTORCNT <= REGISTER_FIS_SECTORCNT-15;
                 currState              <= DMA_WRITE_WAITACK3;
              end
           end

           DMA_WRITE_WAITACK3: begin
              if(from_link_done) begin
                 to_link_done        <= 0;
                 unrecoverable_error <= unrecoverable_error | from_link_err;
                 //if (~from_link_err) begin
                    currState           <= DMA_WRITE_NEXTFIS_DW0;
                 //end
                 //else begin
                   // currState           <= IDLE;
                    //cmd_failed <= 1'b1;
                 //end
              end
           end
           
           DMA_WRITE_NEXTFIS_DW0: begin
              if(from_link_data_en) begin
                 // from_link_data[7:0]  = FIS type
                 // from_link_data[15:8] = C|R|R|Reserved[4:0], C = 0 -> control register, C = 1 -> command register
                 if(from_link_data[7:0] == 16'h34) begin
                    // FIS type == REGISTER FIS -> finished
                    // from_link_data[23:16]  = STATUS
						// from_link_data[31:24] = ERROR
                 // Notice, ERROR is only valid if ERR (STATUS[0]) is reported in STATUS
                 unrecoverable_error <= unrecoverable_error | from_link_data[16];
                 currState           <= DMA_WRITE_WAITACK4;
                 end
                 else if(from_link_data[7:0] == 16'h39) begin
                    // FIS type == DMA Activate -> send more data
                    currState <= DMA_WRITE_WAITDMAACTIVATE;
                 end
              end
           end
           
           DMA_WRITE_WAITACK4: begin
              if(from_link_done) begin
                 if(unrecoverable_error) begin
                    cmd_failed <= 1;
                 end
                 else begin
                    cmd_success <= 1;
                 end
                 currState <= IDLE;
              end
           end
           
           DMA_WRITE_WAITDMAACTIVATE: begin
              if(from_link_done) begin
                 currState <= DMA_WRITE_WAIT_IDLE_1;
              end
           end

           
           /* ------------------------------------------------------------ */
           /* First Party DMA Read (0x60)                                  */
           /* ------------------------------------------------------------ */

           // --- (1) Send Register FIS ----------------------------------
           
           NCQ_READ_WAIT_IDLE_0: begin
              if(from_link_idle) begin
                 to_link_FIS_rdy <= 1;
                 currState       <= NCQ_READ_WAIT_RRDY_0;
              end
              // With asynchronouos I/O it is possible that both host and device
              // want to send a FIS at the same time. Here, if not idle 
              // -> drive wants to transmit: need to relinquish.
              else begin
                 ncq_relinquish <= 1;
                 currState      <= IDLE;
              end
           end 

           NCQ_READ_WAIT_RRDY_0: begin
              to_link_FIS_rdy <= 0;
              
              // need to wait until link layer signals it is ready to receive FIS
              if(from_link_ready_to_transmit) begin
                 currState <= NCQ_READ_DW0;
              end
              
              // with asynchronouos I/O it is possible that both host and device
              // want to send a FIS at the same time. if that happens the link module
              // favors the device and aborts the current transaction issued by the host
              else if(from_link_err) begin
                 ncq_relinquish <= 1;
                 currState      <= IDLE;
              end
           end
           
           NCQ_READ_DW0: begin
				  // FEATURES is now REGISTER_FIS_SECTORCNT, Command = 60 -> First Party DMA Read
              buffer_out_wdata[15:0] <= 16'h8027;
              if(!buffer_out_full) begin
                 buffer_out_wdata_en <= 1;
                 buffer_out_wdata[31:16] <= {REGISTER_FIS_SECTORCNT[7:0],8'h60}; 
                 currState        <= NCQ_READ_DW1;
              end
           end


           NCQ_READ_DW1: begin
					// buffer_out_wdata[15:8] = Device/Head -> FUA|1|R|0|Reserved[3:0]
              // FUA = force unit access bit: for high availability applications.
              // FUA = 1: drive will commit data to media before returning success for the command.
              if(!buffer_out_full) begin
                 buffer_out_wdata[15:0] <= REGISTER_FIS_LBA[15:0];
                 buffer_out_wdata[31:16] <= {8'b01000000,REGISTER_FIS_LBA[23:16]};
                 currState        <= NCQ_READ_DW2;
              end
           end
           
           NCQ_READ_DW2: begin
				// FEATURES (exp) is now REGISTER_FIS_SECTORCNT (exp), Command = 60 -> First Party DMA Read
              if(!buffer_out_full) begin
                 buffer_out_wdata[15:0] <= 16'h0000;
                 buffer_out_wdata[31:16] <= {REGISTER_FIS_SECTORCNT[15:8],8'h00};
                 currState        <= NCQ_READ_DW3;
              end
           end
           
           NCQ_READ_DW3: begin
              //buffer_out_wdata  <= 16'h0028; // REGISTER_FIS_SECTORCNT is now TAG -> [7:3] = Tag, [2:0] reserved. 32 Tags => 0x28 (0010 1000 = 00101XXX -> Tag = 5)
              if(!buffer_out_full) begin
                 buffer_out_wdata[15:8] <= 8'h00;
                 buffer_out_wdata[7:0]  <= {TAG,3'b000};
                 buffer_out_wdata[31:16] <= 16'h0000;
                 currState        <= NCQ_READ_DW4;
              end
           end
           
           NCQ_READ_DW4: begin
              if(!buffer_out_full) begin
                 buffer_out_wdata[15:0] <= 16'h0000;
                 buffer_out_wdata[31:16] <= 16'h0000;
                 currState        <= NCQ_READ_SENDCMD;
              end
           end
           
           NCQ_READ_SENDCMD: begin
              buffer_out_wdata_en <= 0;
              to_link_done        <= 1;
              currState           <= NCQ_READ_WAITACK_1;
           end
           
           NCQ_READ_WAITACK_1: begin
              if(from_link_done) begin
                 to_link_done <= 0;
                 // there was an error receiving the command -> retry
                 if(from_link_err) begin
                    currState <= NCQ_READ_WAIT_IDLE_0;
                 end
                 // command was successful -> receive next FIS
                 else begin
                    currState <= NCQ_READ_REGISTERFIS_DW0;
                 end
              end
           end
           
           // --- (2) Receive Register FIS -------------------------------
           
           NCQ_READ_REGISTERFIS_DW0: begin
              // Read DW0[15:0]
              if(from_link_data_en) begin
                 // from_link_data[7:0]  = FIS type
                 // from_link_data[15:8] = C|R|R|Reserved[4:0], C = 0 -> control register, C = 1 -> command register
                 if(from_link_data[7:0] == 16'h34) begin
                    // FIS type == Register FIS (Ox34) -> finished
                    // from_link_data[15:8]  = STATUS
						// from_link_data[31:16] = ERROR
                 // Notice, ERROR is only valid if ERR (STATUS[0]) is reported in STATUS
                 unrecoverable_error <= unrecoverable_error | from_link_data[16];
                 currState           <= NCQ_READ_WAITACK_2;
                 end
              end
           end

           NCQ_READ_WAITACK_2: begin
              if(from_link_done) begin
                 if(unrecoverable_error) begin
                    cmd_failed <= 1;
                 end
                 else begin
                    cmd_success <= 1;
                 end
                 currState <= IDLE;
              end
           end

           // --- (3) Receive DMA Setup FIS ------------------------------

           // Asynchronous : see NCQ_DMASETUPFIS_DW0_U
           
           // --- (4) Receive Data FIS -----------------------------------
           
           NCQ_READ_DATAFIS_DWI: begin
              // we delay output of data by 32-bit to automatically cut of the CRC at the end of the FIS
              if(from_link_data_en || from_link_data_en_r1) begin
                 from_link_data_en_r1 <= from_link_data_en;
                 from_link_data_en_r2 <= from_link_data_en_r1;
                 from_link_data_en_r3 <= from_link_data_en_r2; 
                 
                 from_link_data_r1 <= from_link_data;
                 from_link_data_r2 <= from_link_data_r1;
                 from_link_data_r3 <= from_link_data_r2;
              end
              else if (~from_link_data_en_r1) begin
                 from_link_data_en_r3 <= 0;
              end
              if(from_link_done) begin
                 unrecoverable_error <= unrecoverable_error | from_link_err;
                 if(unrecoverable_error | from_link_err) begin
                    cmd_failed <= 1;
                 end
                 else begin
                    cmd_success <= 1;
                 end
                 currState <= IDLE;
              end
           end
           
           
           /* ------------------------------------------------------------ */
           /* First Party DMA Write (0x61)                                 */
           /* ------------------------------------------------------------ */

           // --- (1) Send Register FIS ----------------------------------
           
           NCQ_WRITE_WAIT_IDLE_0: begin
              if(from_link_idle) begin
                 to_link_FIS_rdy <= 1;
                 currState       <= NCQ_WRITE_WAIT_RRDY_0;
              end
              // With asynchronouos I/O it is possible that both host and device
              // want to send a FIS at the same time. Here, if not idle 
              // -> drive wants to transmit: need to relinquish.
              else begin
                 ncq_relinquish <= 1;
                 currState      <= IDLE;
              end
           end
           
           NCQ_WRITE_WAIT_RRDY_0: begin
              to_link_FIS_rdy <= 0;

              // need to wait until link layer signals it is ready to receive FIS
              if(from_link_ready_to_transmit) begin
                 currState <= NCQ_WRITE_DW0;
              end
              
              // with asynchronouos I/O it is possible that both host and device
              // want to send a FIS at the same time. if that happens the link module
              // favors the device and aborts the current transaction issued by the host
              else if(from_link_err) begin
                 ncq_relinquish <= 1;
                 currState      <= IDLE;
              end
           end

           NCQ_WRITE_DW0: begin
              buffer_out_wdata[15:0] <= 16'h8027;
              if(!buffer_out_full) begin
                 buffer_out_wdata_en <= 1;
                  buffer_out_wdata[31:16] <= {REGISTER_FIS_SECTORCNT[7:0],8'h61}; // FEATURES is now REGISTER_FIS_SECTORCNT, Command = 61 -> First Party DMA Write
                 currState        <= NCQ_WRITE_DW1;
              end
           end
           
           NCQ_WRITE_DW1: begin
              if(!buffer_out_full) begin
                 buffer_out_wdata[15:0] <= REGISTER_FIS_LBA[15:0];
                 buffer_out_wdata[31:16] <= {8'b01000000,REGISTER_FIS_LBA[23:16]};
                 currState        <= NCQ_WRITE_DW2;
              end
           end
             
           NCQ_WRITE_DW2: begin
			  // FEATURES (exp) is now REGISTER_FIS_SECTORCNT (exp), Command = 61 -> First Party DMA Write
              if(!buffer_out_full) begin
                 buffer_out_wdata[15:0] <= 16'h0000;
                 buffer_out_wdata[31:16] <= {REGISTER_FIS_SECTORCNT[15:8],8'h00};
                 currState        <= NCQ_WRITE_DW3;
              end
           end
                      
           NCQ_WRITE_DW3: begin
              //buffer_out_wdata  <= 16'h0028; // REGISTER_FIS_SECTORCNT is now TAG -> [7:3] = Tag, [2:0] reserved. 32 Tags => 0x28 (0010 1000 = 00101XXX -> Tag = 5)
              if(!buffer_out_full) begin
                 buffer_out_wdata[15:8] <= 8'h00;
                 buffer_out_wdata[7:0]  <= {TAG,3'b000};
                 buffer_out_wdata[31:16] <= 16'h0000;
                 currState        <= NCQ_WRITE_DW4;
              end
           end
           
           NCQ_WRITE_DW4: begin
              if(!buffer_out_full) begin
                 buffer_out_wdata[15:0] <= 16'h0000;
                 buffer_out_wdata[31:16] <= 16'h0000;
                 currState        <= NCQ_WRITE_SENDCMD;
              end
           end
                      
           NCQ_WRITE_SENDCMD: begin
              buffer_out_wdata_en <= 0;
              to_link_done        <= 1;
              currState           <= NCQ_WRITE_WAITACK_1;
           end
           
           NCQ_WRITE_WAITACK_1: begin
              if(from_link_done) begin
                 to_link_done <= 0;
                 // there was an error receiving the command -> retry
                 if(from_link_err) begin
                    currState <= NCQ_WRITE_WAIT_IDLE_0;
                 end
                 // command was successful -> receive next FIS
                 else begin
                    currState <= NCQ_WRITE_REGISTERFIS_DW0;
                 end
              end
           end

           // --- (2) Receive Register FIS -------------------------------
           
           NCQ_WRITE_REGISTERFIS_DW0: begin
              // Read DW0[15:0]
              if(from_link_data_en) begin
                 // from_link_data[7:0]  = FIS type
                 // from_link_data[15:8] = C|R|R|Reserved[4:0], C = 0 -> control register, C = 1 -> command register
                 if(from_link_data[7:0] == 16'h34) begin
                    // FIS type == Register FIS (Ox34) -> finished
                    // from_link_data[23:16]  = STATUS
                 // from_link_data[31:24] = ERROR
                 // Notice, ERROR is only walid if ERR (STATUS[0]) is reported in STATUS
                 unrecoverable_error <= unrecoverable_error | from_link_data[16];
                 currState           <= NCQ_WRITE_WAITACK_2;
                 end
              end
           end
           
           NCQ_WRITE_WAITACK_2: begin
              if(from_link_done) begin
                 if(unrecoverable_error) begin
                    cmd_failed <= 1;
                 end
                 else begin
                    cmd_success <= 1;
                 end
                 currState <= IDLE;
              end
           end

           // --- (3) Receive DMA Setup FIS ------------------------------

           // Asynchronous : see NCQ_DMASETUPFIS_DW0_U
           
           // --- (4) Receive DMA Activate FIS ---------------------------

           NCQ_WRITE_WAIT_IDLE_1: begin
              if(from_link_idle) begin
                 to_link_FIS_rdy <= 1;
                 currState       <= NCQ_WRITE_WAIT_RRDY_1;
              end
           end

           NCQ_WRITE_WAIT_RRDY_1: begin
              to_link_FIS_rdy <= 0;
              currState       <= NCQ_WRITE_DATA_DW0;
           end

           NCQ_WRITE_DATA_DW0: begin
              block_outbuf_reads <= 1;
              // DW0[7:0]  = FIS type: 0x46 (Data FIS)
              // DW0[15:8] = R|R|R|Reserved[4:0]
              buffer_out_wdata[15:0] <= 16'h0046;
				  block_outbuf_reads <= 1;
              // DW0[23:16] = Reserved
              // DW0[31:24] = Reserved
              wordcnt_clear <= 1;
              if(!buffer_out_full) begin
                 buffer_out_wdata_en <= 1;
                 buffer_out_wdata[31:16] <= 16'h0000;
                 currState        <= NCQ_WRITE_WAIT_USER_DATA;
              end
           end

           NCQ_WRITE_WAIT_USER_DATA: begin
              // block Link module reads until user is ready
              wordcnt_clear       <= 0;
              block_outbuf_reads  <= 1;
              block_outbuf_writes <= 0;
              buffer_out_wdata_en <= wdata_en;
              if((!buffer_out_full) && wdata_en) begin
                 buffer_out_wdata <= wdata;
                 
                 // Maximum size of any FIS is 8 KiB
                 // Because the first DW (4 bytes) contains the FIS type (0x46) 
                 // we cannot put more than 15 sectors into a single Data FIS
                 
                 // still need more than one Data FIS to transmit data
                 if(REGISTER_FIS_SECTORCNT > 15) begin
                    currState <= NCQ_WRITE_DATA_USER_1;
                 end
                 // a single FIS is sufficient
                 else begin
                    currState <= NCQ_WRITE_DATA_USER_0;
                 end
              end
           end
           
           NCQ_WRITE_DATA_USER_0: begin
              block_outbuf_writes <= 0;
              buffer_out_wdata_en <= wdata_en;
              if((!buffer_out_full) && wdata_en) begin
                 buffer_out_wdata <= wdata;
              end
              // stop as soon as we wrote enough sectors to the buffer
              if(current_sectorcnt == REGISTER_FIS_SECTORCNT[3:0]) begin
                 to_link_done           <= 1;
                 REGISTER_FIS_SECTORCNT <= ncq_sector_cnt;
                 buffer_out_wdata_en    <= 0;
                 currState              <= NCQ_WRITE_WAITACK3;
              end
           end

           NCQ_WRITE_DATA_USER_1: begin
              block_outbuf_writes <= 0;

              // Need to stop reading from buffer one cycle before current_sectorcnt will be equal to 15
              if((current_sectorcnt == 14)  && (wordcnt[7:0]==8'b1000000) && wordcnt_en) begin
                 block_outbuf_writes <= 1;
              end
              
              buffer_out_wdata_en <= wdata_en;                 
              if((!buffer_out_full) && wdata_en) begin
                 buffer_out_wdata <= wdata;
              end
              
              // Maximum size of any FIS is 8 KiB
              // Because the first DW (4 bytes) contains the FIS type (0x46) 
              // we cannot put more than 15 sectors into a single Data FIS              
              if(current_sectorcnt == 15) begin
                 block_outbuf_writes    <= 1;
                 to_link_done           <= 1;
                 buffer_out_wdata_en    <= 0;
                 REGISTER_FIS_SECTORCNT <= REGISTER_FIS_SECTORCNT-15;
                 currState              <= NCQ_WRITE_WAITACK3;
              end
           end
           
           NCQ_WRITE_WAITACK3: begin
              ncq_ready_for_wdata <= 0;
              if(from_link_done) begin
                 to_link_done        <= 0;
                 unrecoverable_error <= unrecoverable_error | from_link_err;
                 if(unrecoverable_error | from_link_err) begin
                    cmd_failed <= 1;
                 end
                 else begin
                    cmd_success <= 1;
                 end
                 currState <= IDLE;
              end
           end

           
           /* ------------------------------------------------------------ */
           /* NCQ : Asynchronous receive DMA Setup FIS                     */
           /* ------------------------------------------------------------ */

           NCQ_DMASETUPFIS_DW1: begin
              if(from_link_data_en) begin
                 // from_link_data[7:0]  = TAG
                 // from_link_data[15:8] = 0
                 ncq_rtag  <= from_link_data[4:0];
                 currState <= NCQ_WAITACK_1;
              end
           end

           NCQ_WAITACK_1: begin
              if(from_link_done) begin
                 currState <= NCQ_DATAFIS_DW0;
              end
           end
           
           NCQ_DATAFIS_DW0: begin
              if(from_link_data_en) begin
                 if(from_link_data[7:0] == 8'h46) begin
                    // from_link_data[7:0] = FIS type (16'h41 = Data FIS)
                    from_link_data_en_r1 <= 0;
						  from_link_data_en_r2 <= 0;
						  currState            <= NCQ_READ_DATAFIS_DWI;
                 end
                 else if(from_link_data[7:0] == 8'h39) begin
                    // from_link_data[7:0] = FIS type (16'h39 = DMA Activate)
                    ncq_ready_for_wdata <= 1;
						  if(from_link_done) begin
								currState <= NCQ_WRITE_WAIT_IDLE_1;
						  end
                 end
              end
           end

           
           /* ------------------------------------------------------------ */
           /* NCQ : Asynchronous receive SetDevBits FIS                    */
           /* ------------------------------------------------------------ */

           NCQ_SETDEVBITSFIS_DW1: begin
              if(from_link_data_en) begin
                 ncq_SActive[31:0] <= from_link_data;
                 currState          <= NCQ_WAITACK_2;
              end
           end

           NCQ_WAITACK_2: begin
              if(from_link_done) begin
                 cmd_success       <= 1;
                 ncq_SActive_valid <= 1;
                 currState         <= IDLE;
              end
           end

           default: begin
              currState <= IDLE;
           end
           
         endcase
      end
   end
   
   // count words in sector
   always @(posedge clk) 
      if(reset) 
         wordcnt <= 0;
      else if(wordcnt_clear)
         wordcnt <= 0;
      else if(wordcnt_en & (wordcnt == 8'b10000000))
         wordcnt <= 1;
      else if (wordcnt_en) 
         wordcnt <= wordcnt+1;
        
 
   
   // count sectors in data FIS
   always @(posedge clk) begin
      if(reset) begin
         current_sectorcnt <= 0;
      end
      else begin
         if(wordcnt_clear) begin
            current_sectorcnt <= 0;
         end 
			// Lisa: if wordcnt == 128 another sector has been processed
         else if ((wordcnt[7:0] == 8'b10000000) & wordcnt_en) begin // (wordcnt_en && (wordcnt[6:0] == 7'b1111111) begin //(wordcnt==8'hFE)) begin
            current_sectorcnt <= current_sectorcnt+1;
         end
      end
   end

   // buffer incoming traffic
   // after immenent overflow we still need to be able to buffer 20 DWs -> 40 Ws
   /*FIFO 
     #(
       .WIDTH       (32),
       .DEPTH       (64),
       .ADDR_BITS   (6),
       .OVERFLOWLIM (8)
       )
   BufferIn0
     (
      .clk         (clk),
      .reset       (reset),
      .dataIn      (from_link_data_r3),
      .dataInWrite (from_link_data_en_r3),
      .dataOut     (rdata),
      .dataOutRead (rdata_next),
      .empty       (rdata_empty),
      .full        (),
      .underrun    (),
      .overflow    (to_link_receive_overflow)
      );*/
      
    FIS_IN_FIFO BufferIn0 (
        .clk(clk),              // input wire clk
        .rst(reset),              // input wire rst
        .din(from_link_data_r3),              // input wire [31 : 0] din
        .wr_en(from_link_data_en_r3),          // input wire wr_en
        .rd_en(rdata_next),          // input wire rd_en
        .dout(rdata),            // output wire [31 : 0] dout
        .full(),            // output wire full
        .empty(rdata_empty),          // output wire empty
        .prog_full(to_link_receive_overflow)  // output wire prog_full
    );
   
   // buffer outgoing traffic
  /* FIFO 
     #(
       .WIDTH       (32),
       .DEPTH       (16),
       .ADDR_BITS   (4),
       .UNDERRUNLIM (3),
       .OVERFLOWLIM (12)
       )
   BufferOut0
     (
      .clk         (clk),
      .reset       (reset),
      .dataIn      (buffer_out_wdata),
      .dataInWrite (buffer_out_wdata_en),
      .dataOut     (to_link_data),
      .dataOutRead (from_link_next & ~buffer_out_empty),
      .empty       (buffer_out_empty),
      .full        (buffer_out_full),
      .underrun    (buffer_out_underrun),
      .overflow    (buffer_out_overflow)
      );*/  
	 FIS_OUT_FIFO BufferOut0 (
        .clk(clk),                // input wire clk
        .rst(reset),                // input wire rst
        .din(buffer_out_wdata),                // input wire [31 : 0] din
        .wr_en(buffer_out_wdata_en),            // input wire wr_en
        .rd_en(from_link_next & ~buffer_out_empty),            // input wire rd_en
        .dout(to_link_data),              // output wire [31 : 0] dout
        .full(buffer_out_full),              // output wire full
        .empty(buffer_out_empty),            // output wire empty
        .prog_full(buffer_out_overflow),    // output wire prog_full
        .prog_empty(buffer_out_underrun)  // output wire prog_empty
      );	
   /* ------------------------------------------------------------ */
   /* ChipScope Debugging                                          */
   /* ------------------------------------------------------------ */
/*
   reg [256:0] data;
   reg [31:0]  trig0;
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

   // --- data monitor -------------------------------------------
always @(posedge clk) begin
   data[6:0]   <= currState;
   data[38:7]  <= to_link_data;
   data[39] <= buffer_out_empty; //from_link_data_en;
   data[40] <= cmd_failed;
   data[41] <= cmd_success;
   data[44:42] <= cmd;
   data[45] <= cmd_en;
   data[77:46] <= lba[31:0];
   data[78] <= from_link_idle;
   data[79] <= from_link_done;
   data[80] <= from_link_err;
   data[81] <= from_link_next;
   data[82] <= from_link_ready_to_transmit;
   data[114:83] <= from_link_data; //wdata; //buffer_out_wdata;
   data[115] <= wdata_en; //buffer_out_wdata_en;
   data[116] <= wdata_full;
   data[117] <= buffer_out_underrun;
   data[118] <= buffer_out_overflow;
   data[119] <= buffer_out_full;
   data[120] <= to_link_send_empty;
   data[121] <= to_link_send_underrun;
   data[122] <= from_link_data_en;
   data[154:123] <= latency_r;
   
   trig0[6:0]  <= currState;
   trig0[7]    <= cmd_failed;
   trig0[8]    <= cmd_success;
   trig0[9]    <= buffer_out_wdata_en;
   trig0[10]   <= buffer_out_empty;
   trig0[11] <= cmd_en;
   trig0[12] <= wdata_full;
   trig0[13] <= wdata_en;
end*/

endmodule
