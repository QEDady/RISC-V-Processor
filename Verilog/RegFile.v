`timescale 1ns / 1ps
/*******************************************************************
*
* Module: RegFile.v
* Project: rv32i_processor
* Author: Amer Elsheikh - Gehad Ahmed
* Description: ---
*
* Change history: 07/04/23 - Added the RegFile code (Gehad)
*
**********************************************************************/

module RegFile(
    input  wire        clk, rst, reg_write, 
    input  wire [4:0]  rs1, rs2, rd, 
    input  wire [31:0] write_data, 
    output wire [31:0] read_data1, read_data2);
    
    reg [31:0] RegFile [31:0];
    
    assign read_data1 = RegFile[rs1];
    assign read_data2 = RegFile[rs2];
    
    integer i; 
    always@(posedge clk)
    begin
        if (rst) begin
            for(i = 0; i < 32; i = i + 1) RegFile[i] = 0;
        end
        else if (reg_write && rd != 0)
            RegFile[rd] = write_data;
    end

endmodule
