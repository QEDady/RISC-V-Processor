`include "defines.v"
`timescale 1ns / 1ps
/*******************************************************************
*
* Module: BranchUnit.v
* Project: rv32i_processor
* Author: Amer Elsheikh - Gehad Ahmed 
* Description: ---
*
* Change history: 07/04/23 - Added the BranchUnit code (Amer)
*
**********************************************************************/


module BranchUnit(
    input  wire       cf, zf, vf, sf, branch,
    input  wire [2:0] func3,
    output reg        exec_branch
);

    always @(*) begin 
        exec_branch = 0;
        if (branch) begin
            case (func3) 
                `BR_BEQ: exec_branch = zf;
                `BR_BNE: exec_branch = ~zf;
                `BR_BLT: exec_branch = (sf != vf);
                `BR_BGE: exec_branch = (sf == vf);
                `BR_BLTU: exec_branch = ~cf;
                `BR_BGEU: exec_branch = cf;
                default: exec_branch = 0;
            endcase
        end
    end

endmodule
