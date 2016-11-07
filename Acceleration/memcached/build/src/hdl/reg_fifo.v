`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 03/10/2014 09:54:34 AM
// Design Name: 
// Module Name: reg_fifo
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


module reg_fifo
#(parameter
    DATA_BITS  = 8,
    DEPTH_BITS = 4
)(
    input  wire                 clk,
    input  wire                 nReset,
    output wire                 empty_n,
    output wire                 full_n,
    input  wire                 read,
    input  wire                 write,
    output wire [DATA_BITS-1:0] dout,
    input  wire [DATA_BITS-1:0] din
);
//------------------------Parameter----------------------
localparam
    DEPTH = 1 << DEPTH_BITS;
//------------------------Local signal-------------------
reg                   empty;
reg                   full;
reg  [DEPTH_BITS-1:0] index;
reg  [DATA_BITS-1:0]  mem[0:DEPTH-1];
//------------------------Body---------------------------
assign empty_n = ~empty;
assign full_n  = ~full;
assign dout    = mem[index];

// empty
always @(posedge clk) begin
    if (~nReset)
        empty <= 1'b1;
    else if (empty & write & ~read)
        empty <= 1'b0;
    else if (~empty & ~write & read & (index==1'b0))
        empty <= 1'b1;
end

// full
always @(posedge clk) begin
    if (~nReset)
        full <= 1'b0;
    else if (full & read & ~write)
        full <= 1'b0;
    else if (~full & ~read & write & (index==DEPTH-2'd2))
        full <= 1'b1;
end

// index
always @(posedge clk) begin
    if (~nReset)
        index <= {DEPTH_BITS{1'b1}};
    else if (~empty & ~write & read)
        index <= index - 1'b1;
    else if (~full & ~read & write)
        index <= index + 1'b1;
end

// mem
always @(posedge clk) begin
    if (~full & write) mem[0] <= din;
end

genvar i;
generate
    for (i = 1; i < DEPTH; i = i + 1) begin : gen_sr
        always @(posedge clk) begin
            if (~full & write) mem[i] <= mem[i-1];
        end
    end
endgenerate

endmodule
