`timescale 1ns / 1ps
/*******************************************************************
*
* Module: ControlUnit.v
* Project: rv32i_processor
* Author: Amer Elsheikh - Gehad Ahmed
* Description: ---
*
* Change history: 07/04/23 - Added the ControlUnit code (Amer)
*                 08/04/23 - Added the control signals for all instructions (Amer - Gehad)
*
**********************************************************************/

module ControlUnit(
    input  wire [4:0] opcode, 
    input  wire       inst20,
    output reg        mem_read, mem_to_reg, mem_write, ALU_src, reg_write, 
    output reg        branch, jal, jalr, auipc, freeze_pc, zero_pc,
    output reg  [1:0] ALU_op
);

    always @(*) begin
        case (opcode)
           `OPCODE_Load: begin 
                {mem_read, mem_to_reg, mem_write, ALU_src, reg_write} = 5'b11011;
                {branch, jal, jalr, auipc, freeze_pc, zero_pc} = 6'b000000;
                ALU_op = 2'b00;
            end
            `OPCODE_Store: begin 
                {mem_read, mem_to_reg, mem_write, ALU_src, reg_write} = 5'b00110;
                {branch, jal, jalr, auipc, freeze_pc, zero_pc} = 6'b000000;
                ALU_op = 2'b00;
            end
            `OPCODE_Branch: begin 
                {mem_read, mem_to_reg, mem_write, ALU_src, reg_write} = 5'b00000;
                {branch, jal, jalr, auipc, freeze_pc, zero_pc} = 6'b100000;
                ALU_op = 2'b01;
            end
            `OPCODE_Arith_R: begin 
                {mem_read, mem_to_reg, mem_write, ALU_src, reg_write} = 5'b00001;
                {branch, jal, jalr, auipc, freeze_pc, zero_pc} = 6'b000000;
                ALU_op = 2'b10;
            end
            `OPCODE_Arith_I: begin 
                {mem_read, mem_to_reg, mem_write, ALU_src, reg_write} = 5'b00011;
                {branch, jal, jalr, auipc, freeze_pc, zero_pc} = 6'b000000;
                ALU_op = 2'b10;
            end
            `OPCODE_JALR: begin 
                {mem_read, mem_to_reg, mem_write, ALU_src, reg_write} = 5'b00011;
                {branch, jal, jalr, auipc, freeze_pc, zero_pc} = 6'b001000;
                ALU_op = 2'b00;
            end
            `OPCODE_JAL: begin 
                {mem_read, mem_to_reg, mem_write, ALU_src, reg_write} = 5'b00001;
                {branch, jal, jalr, auipc, freeze_pc, zero_pc} = 6'b010000;
                ALU_op = 2'b00;
            end
            `OPCODE_AUIPC: begin 
                {mem_read, mem_to_reg, mem_write, ALU_src, reg_write} = 5'b00001;
                {branch, jal, jalr, auipc, freeze_pc, zero_pc} = 6'b000100;
                ALU_op = 2'b00;
            end
            `OPCODE_LUI: begin 
                {mem_read, mem_to_reg, mem_write, ALU_src, reg_write} = 5'b00011;
                {branch, jal, jalr, auipc, freeze_pc, zero_pc} = 6'b000000;
                ALU_op = 2'b11;
            end
            `OPCODE_SYSTEM: begin 
                {mem_read, mem_to_reg, mem_write, ALU_src, reg_write} = 5'b00000;
                {branch, jal, jalr, auipc, freeze_pc, zero_pc} = inst20 ? 6'b000010 : 6'b000001;
                ALU_op = 2'b00;
            end
            `OPCODE_FENCE: begin 
                {mem_read, mem_to_reg, mem_write, ALU_src, reg_write} = 5'b00000;
                {branch, jal, jalr, auipc, freeze_pc, zero_pc} = 6'b000001;
                ALU_op = 2'b00;
            end
        endcase
    end
    
endmodule
