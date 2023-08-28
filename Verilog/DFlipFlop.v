`timescale 1ns / 1ps
/*******************************************************************
*
* Module: DFlipFlop.v
* Project: rv32i_processor
* Author: Amer Elsheikh - Gehad Ahmed
*
* Change history: 07/04/23 - Added the DFlipFlop code (Amer)
*
**********************************************************************/


module DFlipFlop (
    input  wire clk, rst, D, 
    output reg Q
);
    always @ (posedge clk or posedge rst) begin
        if (rst) Q <= 1'b0;
        else Q <= D;
    end
endmodule 