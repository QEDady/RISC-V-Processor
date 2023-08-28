`include "defines.v"
`timescale 1ns / 1ps
/*******************************************************************
*
* Module: ALUControlUnit.v
* Project: rv32i_processor
* Author: Amer Elsheikh - Gehad Ahmed 
*
* Change history: 07/04/23 - Added the ALUControlUnit code (Gehad)
*                 07/04/23 - Added support for R - I (without loads) types (Gehad)
*                 17/04/23 - Solved a bug for the I type instructions (Gehad)
*
**********************************************************************/

module ALUControlUnit(
    input  wire       inst30, 
    input  wire       inst25,
    input  wire       inst5,  
    input  wire [2:0] func3, 
    input  wire [1:0] ALU_op, 
    output reg  [4:0] ALU_sel 
);
    
    always@(*)
    begin 
        if (ALU_op == 2'b00) 
            ALU_sel = `ALU_ADD;
        else if (ALU_op == 2'b01)
            ALU_sel = `ALU_SUB;
        else if (ALU_op == 2'b11)
            ALU_sel = `ALU_PASS;
        else
        begin 
            if (inst5) begin // not immediate 
                if (inst25) begin
                    case (func3)
                        `F3_MUL   : ALU_sel = `ALU_MUL;
                        `F3_MULH  : ALU_sel = `ALU_MULH;
                        `F3_MULHSU: ALU_sel = `ALU_MULHSU;
                        `F3_MULHU : ALU_sel = `ALU_MULHU;
                        `F3_DIV   : ALU_sel = `ALU_DIV;
                        `F3_DIVU  : ALU_sel = `ALU_DIVU;
                        `F3_REM   : ALU_sel = `ALU_REM;
                        `F3_REMU  : ALU_sel = `ALU_REMU;
                        default: ALU_sel = 0;
                    endcase
                end else begin
                    case ({inst30, func3})
                        4'b0000: ALU_sel = `ALU_ADD;
                        4'b1000: ALU_sel = `ALU_SUB;
                        4'b0001: ALU_sel = `ALU_SLL;
                        4'b0010: ALU_sel = `ALU_SLT;
                        4'b0011: ALU_sel = `ALU_SLTU;
                        4'b0100: ALU_sel = `ALU_XOR;
                        4'b0101: ALU_sel = `ALU_SRL;
                        4'b1101: ALU_sel = `ALU_SRA;
                        4'b0110: ALU_sel = `ALU_OR;
                        4'b0111: ALU_sel = `ALU_AND;
                        default: ALU_sel = 0;
                    endcase
                end
             end else begin
                case (func3) 
                    3'b000: ALU_sel = `ALU_ADD;
                    3'b001: ALU_sel = `ALU_SLL;
                    3'b010: ALU_sel = `ALU_SLT;
                    3'b011: ALU_sel = `ALU_SLTU;
                    3'b100: ALU_sel = `ALU_XOR;
                    3'b101: ALU_sel = inst30 ? `ALU_SRA : `ALU_SRL;
                    3'b110: ALU_sel = `ALU_OR;
                    3'b111: ALU_sel = `ALU_AND;
                    default: ALU_sel = 0;
                endcase
             end
        end
    end

endmodule
