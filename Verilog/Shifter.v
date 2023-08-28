`timescale 1ns / 1ps
/*******************************************************************
*
* Module: Shifter.v
* Project: rv32i_processor
* Author: Amer Elsheikh - Gehad Ahmed 
*
* Change history: 07/04/23 - Wrote the shifter module (Gehad)
*
*
* Notes: {n{bit}} don't work if n is a variable 

**********************************************************************/


module Shifter(
    input   wire [31:0] a,
    input   wire [4:0]  shamt,
    input   wire [1:0]  type,
    output  reg  [31:0] r 
);

    wire [4:0] sh;
    assign sh = shamt;

    always @(*) begin
        case (type)
            2'b01: r = a << shamt; // sll
            2'b00: r = a >> shamt; // srl
            2'b10: r = $signed(a) >>> shamt; // sra
            default: r = 0;
        endcase  
    end

endmodule