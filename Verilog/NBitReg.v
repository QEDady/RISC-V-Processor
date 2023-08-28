`timescale 1ns / 1ps
/*******************************************************************
*
* Module: NBitReg.v
* Project: rv32i_processor
* Author: Amer Elsheikh - Gehad Ahmed
*
* Change history: 07/04/23 - Added the NBitReg code (Amer)
*
**********************************************************************/


module NBitReg #(parameter N = 32) (
    input  wire clk, rst, load, 
    input  wire [N-1:0] D, 
    output wire [N-1:0] Q
);
    
    wire [N-1:0] new_Q;
    assign new_Q = (load ? D : Q);
    
    genvar i;
    generate
        for(i = 0; i < N; i = i+1)
        begin: Gen_Modules
            DFlipFlop DFF (.clk(clk),  .rst(rst), .D(new_Q[i]), .Q(Q[i]));
        end
    endgenerate
    
endmodule
