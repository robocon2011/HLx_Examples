///////////////////////////////////////////////////////////////////////////////
// Copyright (c) 2014 Xilinx, Inc.
// All Rights Reserved
///////////////////////////////////////////////////////////////////////////////
//   ____  ____
//  /   /\/   /
// /___/  \  /    Vendor     : Xilinx
// \   \   \/     Version    : 14.6
//  \   \         Application: Xilinx CORE Generator
//  /   /         Filename   : chipscope_vio.v
// /___/   /\     Timestamp  : Fri May 23 08:22:19 GMT Daylight Time 2014
// \   \  /  \
//  \___\/\___\
//
// Design Name: Verilog Synthesis Wrapper
///////////////////////////////////////////////////////////////////////////////
// This wrapper is used to integrate with Project Navigator and PlanAhead

`timescale 1ns/1ps

module chipscope_vio(
    CONTROL,
    ASYNC_OUT) /* synthesis syn_black_box syn_noprune=1 */;


inout [35 : 0] CONTROL;
output [0 : 0] ASYNC_OUT;

endmodule
