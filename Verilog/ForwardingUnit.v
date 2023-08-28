`timescale 1ns / 1ps
/*******************************************************************
*
* Project: rv32i_processor
* Author: Amer Elsheikh - Gehad Ahmed
* Description: ---
*
* Change history: 28/04/23 - Combined the modules in a pipelined processor (Gehad - Amer)
*
**********************************************************************/


module ForwardingUnit(
    input  wire       MEM_WB_RegWrite,
    input  wire [4:0] ID_EX_RegisterRs1, ID_EX_RegisterRs2, MEM_WB_RegisterRd,
    output reg        forwardA , forwardB
);
    
      always@(*) begin 
        
        if (MEM_WB_RegWrite && MEM_WB_RegisterRd != 0 && MEM_WB_RegisterRd == ID_EX_RegisterRs1)
            forwardA = 1'b1;
        else
            forwardA = 1'b0; 
            
        if (MEM_WB_RegWrite && MEM_WB_RegisterRd != 0 && MEM_WB_RegisterRd == ID_EX_RegisterRs2)
            forwardB = 1'b1;
        else
            forwardB = 1'b0; 
    end

endmodule
