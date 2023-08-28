`include "defines.v"
`timescale 1ns / 1ps
/*******************************************************************
*
* Module: Memory.v
* Project: rv32i_processor
* Author: Amer Elsheikh - Gehad Ahmed
* Description: ---
*
* Change history: 08/04/23 - Added the data memory with support to byte addressable (signed or unsigned) data (Gehad - Amer)
*
**********************************************************************/


module Memory(
    input  wire        clk, MemRead, MemWrite, 
    input  wire [2:0]  func3, 
    input  wire [11:0] addr, 
    input  wire [31:0] data_in, 
    output reg  [31:0] data_out
);
   reg [7:0] mem[1*(1024-1):0]; // 4KB memory
    // reg [7:0] mem[200:0]; // Small memory for the FPGA
    
    // Program 1: Basic Program
    integer i = 500;
    initial begin
    
        $readmemh("program1.mem",mem);

        {mem[503], mem[502], mem[501], mem[500]} = 32'd17; 
        {mem[507], mem[506], mem[505], mem[504]} = 32'd9; 
        {mem[511], mem[510], mem[509], mem[508]} = 32'd25;    
        
// Program 3
//         {mem[i+3], mem[i+2], mem[i+1], mem[i]} = -32'd1;
//         i = i + 4;   
//         {mem[i+3], mem[i+2], mem[i+1], mem[i]} = 32'h0f0f0f0f;
//         i = i + 12;   
//         {mem[i+3], mem[i+2], mem[i+1], mem[i]} = 32'hf0f0f0f0;
//         i = i + 4;      
    end 

    always @(*) begin
        case (func3)
            `F3_Byte: data_out = {{24{mem[addr][7]}}, mem[addr]};
            `F3_Half: data_out = {{16{mem[addr + 1][7]}}, mem[addr + 1], mem[addr]};
            `F3_Word: data_out = {mem[addr + 3], mem[addr + 2], mem[addr + 1], mem[addr]};
            `F3_ByteU: data_out = {24'b0, mem[addr]};
            `F3_HalfU: data_out = {16'b0, mem[addr + 1], mem[addr]};
        endcase
    end
    
    always @(posedge clk) begin
        if (MemWrite) begin 
            case (func3)
                `F3_Byte: mem[addr] <= data_in[7:0];
                `F3_Half: {mem[addr + 1], mem[addr]} <= data_in[15:0];
                `F3_Word: {mem[addr + 3], mem[addr + 2], mem[addr + 1], mem[addr]} <= data_in;
            endcase
        end 
    end
    
endmodule


