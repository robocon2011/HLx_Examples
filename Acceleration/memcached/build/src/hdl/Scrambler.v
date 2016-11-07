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
 * Created       : April 15 2011 by Louis
 * Last Update   : March 15 2012 by Louis
 * Update		  : September 10 2013 by Lisa, implemented the scrambler as described in the appendix A of SATA spec.
 * ---------------------------------------------------------------------------
 * Description   : FIS Scrambler Module: G(x) = x^16+x^15+x^13+x^4+1
 * ------------------------------------------------------------------------- */

`timescale 1 ns / 1 ps

module Scrambler
  (
   input             clk,
   input             reset,
   input             enable,
   input             nopause,
   output[31:0] scramblemask
   );

   reg [31:0] currScramble_r; 
	reg [31:0] nextScramble_r;
	reg enable_r;
	
	wire [15:0] context; //store upper 16 bits of register currScramble_r to hold the context or state
   
	assign scramblemask = currScramble_r;
	assign context = nextScramble_r[31:16];
	
	always @(posedge clk)
		if (reset)
			enable_r <= 1'b0;
		else if (enable)
			enable_r <= 1'b1;
   
   always @(posedge clk) 
      if(reset) begin
         // initialize scrambler to 0xF0F6
			nextScramble_r <= 32'hF0F60000;
         currScramble_r[31:0] <= 32'b0;
      end
      else begin 
         if (nopause) begin
            currScramble_r <= nextScramble_r;
         end
	      
			if (enable | (enable_r && nopause)) begin
				/* The following 16 assignments implement the matrix multiplication */	
				/* performed by the box labeled *M1. */
				nextScramble_r[31] <= (((((context[12] ^ context[10]) ^ context[7]) ^ context[3]) ^ context[1]) ^ context[0]);
				nextScramble_r[30] <= context[15] ^ context[14] ^ context[12] ^ context[11] ^ context[9] ^ context[6] ^ context[3] ^ context[2] ^ context[0];
				nextScramble_r[29] <= context[15] ^ context[13] ^ context[12] ^ context[11] ^ context[10] ^ context[8] ^ context[5] ^ context[3] ^ context[2] ^ context[1];
				nextScramble_r[28] <= context[14] ^ context[12] ^ context[11] ^ context[10] ^ context[9] ^ context[7] ^ context[4] ^ context[2] ^ context[1] ^ context[0];
				nextScramble_r[27] <= context[15] ^ context[14] ^ context[13] ^ context[12] ^ context[11] ^ context[10] ^ context[9] ^ context[8] ^ context[6] ^ context[1] ^ context[0];
				nextScramble_r[26] <= context[15] ^ context[13] ^ context[11] ^ context[10] ^ context[9] ^ context[8] ^ context[7] ^ context[5] ^ context[3] ^ context[0];
				nextScramble_r[25] <= context[15] ^ context[10] ^ context[9] ^ context[8] ^ context[7] ^ context[6] ^ context[4] ^ context[3] ^ context[2];
				nextScramble_r[24] <= context[14] ^ context[9] ^ context[8] ^ context[7] ^ context[6] ^ context[5] ^ context[3] ^ context[2] ^ context[1];
				nextScramble_r[23] <= context[13] ^ context[8] ^ context[7] ^ context[6] ^ context[5] ^ context[4] ^ context[2] ^ context[1] ^ context[0];
				nextScramble_r[22] <= context[15] ^ context[14] ^ context[7] ^ context[6] ^ context[5] ^ context[4] ^ context[1] ^ context[0];
				nextScramble_r[21] <= context[15] ^ context[13] ^ context[12] ^ context[6] ^ context[5] ^ context[4] ^ context[0];
				nextScramble_r[20] <= context[15] ^ context[11] ^ context[5] ^ context[4];
				nextScramble_r[19] <= context[14] ^ context[10] ^ context[4] ^ context[3];
				nextScramble_r[18] <= context[13] ^ context[9] ^ context[3] ^ context[2];
				nextScramble_r[17] <= context[12] ^ context[8] ^ context[2] ^ context[1];
				nextScramble_r[16] <= context[11] ^ context[7] ^ context[1] ^ context[0];
				
				/* The following 16 assignments implement the matrix multiplication */
				/* performed by the box labeled *M2. */
				nextScramble_r[15] <= context[15] ^ context[14] ^ context[12] ^ context[10] ^ context[6] ^ context[3] ^ context[0];
				nextScramble_r[14] <= context[15] ^ context[13] ^ context[12] ^ context[11] ^ context[9] ^ context[5] ^ context[3] ^ context[2];
				nextScramble_r[13] <= context[14] ^ context[12] ^ context[11] ^ context[10] ^ context[8] ^ context[4] ^ context[2] ^ context[1];
				nextScramble_r[12] <= context[13] ^ context[11] ^ context[10] ^ context[9] ^ context[7] ^ context[3] ^ context[1] ^ context[0];
				nextScramble_r[11] <= context[15] ^ context[14] ^ context[10] ^ context[9] ^ context[8] ^ context[6] ^ context[3] ^ context[2] ^ context[0];
				nextScramble_r[10] <= context[15] ^ context[13] ^ context[12] ^ context[9] ^ context[8] ^ context[7] ^ context[5] ^ context[3] ^ context[2] ^ context[1];
				nextScramble_r[9] <= context[14] ^ context[12] ^ context[11] ^ context[8] ^ context[7] ^ context[6] ^ context[4] ^ context[2] ^ context[1] ^ context[0];
				nextScramble_r[8] <= context[15] ^ context[14] ^ context[13] ^ context[12] ^ context[11] ^ context[10] ^ context[7] ^ context[6] ^ context[5] ^ context[1] ^ context[0];
				nextScramble_r[7] <= context[15] ^ context[13] ^ context[11] ^ context[10] ^ context[9] ^ context[6] ^ context[5] ^ context[4] ^ context[3] ^ context[0];
				nextScramble_r[6] <= context[15] ^ context[10] ^ context[9] ^ context[8] ^ context[5] ^ context[4] ^ context[2];
				nextScramble_r[5] <= context[14] ^ context[9] ^ context[8] ^ context[7] ^ context[4] ^ context[3] ^ context[1];
				nextScramble_r[4] <= context[13] ^ context[8] ^ context[7] ^ context[6] ^ context[3] ^ context[2] ^ context[0];
				nextScramble_r[3] <= context[15] ^ context[14] ^ context[7] ^ context[6] ^ context[5] ^ context[3] ^ context[2] ^ context[1];
				nextScramble_r[2] <= context[14] ^ context[13] ^ context[6] ^ context[5] ^ context[4] ^ context[2] ^ context[1] ^ context[0];
				nextScramble_r[1] <= context[15] ^ context[14] ^ context[13] ^ context[5] ^ context[4] ^ context[1] ^ context[0];
				nextScramble_r[0] <= context[15] ^ context[13] ^ context[4] ^ context[0];
		end
	end
	
	
   /* ------------------------------------------------------------ */
   /* ChipScope Debugging                                          */
   /* ------------------------------------------------------------ */
/*
   wire [127:0] data;
   wire [15:0]  trig0;
   wire [35:0]  control;

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
		
	assign data[0] = reset;
	assign data[1] = enable;
	assign data[2] = nopause;
	assign data[34:3] = nextScramble_r[31:0];
	assign data[66:35] = currScramble_r[31:0];
	assign data[70] = enable_r;
	
	assign trig0[0] = reset;
	assign trig0[1] = enable;
	assign trig0[2] = nopause;
*/        
endmodule
