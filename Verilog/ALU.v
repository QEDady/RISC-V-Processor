`include "defines.v"
`timescale 1ns / 1ps
/*******************************************************************
*
* Module: ALU.v
* Project: rv32i_processor
* Author: Amer Elsheikh - Gehad Ahmed (Taken from Dr. Cherif Salama)
*
* Change history: 07/04/23 - Imported the code created by Dr. Cherif (Gehad)
*
**********************************************************************/


module ALU(
	input   wire [31:0] a, b,
	input   wire [4:0]  shamt,
	input   wire [4:0]  alufn,
	output  reg  [31:0] r,
	output  wire        cf, zf, vf, sf
);

    wire [31:0] add, sub, op_b;
    reg [31:0] throw_away;
    wire [63:0] mul;
    wire cfa, cfs;
    
    assign op_b = (~b);
    
    assign {cf, add} = alufn[0] ? (a + op_b + 1'b1) : (a + b);
    assign mul = a * b;
    
    assign zf = (add == 0);
    assign sf = add[31];
    assign vf = (a[31] ^ (op_b[31]) ^ add[31] ^ cf);
    
    wire[31:0] sh;
    Shifter shifter0(.a(a), .shamt(shamt), .type(alufn[1:0]),  .r(sh));
    
    always @(*) begin
        r = 0;
        (* parallel_case *)
        case (alufn)
            // arithmetic
            `ALU_ADD:   r = add;
            `ALU_SUB:   r = add;
            `ALU_PASS:  r = b; // pass (used in LUI) 
            // logic
            `ALU_OR:    r = a | b;
            `ALU_AND:   r = a & b;
            `ALU_XOR:   r = a ^ b;
            // shift
            `ALU_SRL:   r = sh;
            `ALU_SLL:   r = sh;
            `ALU_SRA:   r = sh;
            // slt & sltu
            `ALU_SLT:   r = {31'b0,(sf != vf)}; 
            `ALU_SLTU:  r = {31'b0,(~cf)};    
            // mul extension        	
            `ALU_MUL:    r = a * b;      
            `ALU_MULH:   {r, throw_away} = $signed(a) * $signed(b);  
            `ALU_MULHSU: {r, throw_away} = $signed(a) * $signed({1'b0, b});   
            `ALU_MULHU:  {r, throw_away} = a * b;   
            `ALU_DIV:    r = $signed(a) / $signed(b);      
            `ALU_DIVU:   r = a / b;     
            `ALU_REM:    r = $signed(a) % $signed(b);      
            `ALU_REMU:   r = a % b;     
        endcase
    end
endmodule