`include "defines.v"
`timescale 1ns / 1ps
/*******************************************************************
*
* Module: Pipelined.v
* Project: rv32i_processor
* Author: Amer Elsheikh - Gehad Ahmed
* Description: ---
*
* Change history: 28/04/23 - Combined the modules in a pipelined processor (Gehad - Amer)
*
**********************************************************************/


module Pipelined(
    input  wire        clk, rst, clk_ssd, 
    input  wire [1:0]  led_sel, 
    input  wire [3:0]  ssd_sel, 
    output reg  [15:0] leds, 
    output wire [3:0]  anode, 
    output wire [6:0]  led_out
);

    localparam N = 32;

    wire cf, zf, vf, sf, exec_branch;
    wire mem_read, mem_to_reg, mem_write, ALU_src, reg_write;
    wire branch, jal, jalr, auipc, freeze_pc, zero_pc;
    wire forwardA, forwardB;
    wire [1:0] ALU_op;
    wire [4:0] ALU_sel;
    wire [N-1:0] cur_PC, target_PC;
    reg  [N-1:0] new_PC, write_data, inst, mem_data_out;
    wire [N-1:0] read_data1, read_data2, imm, ALU_out, ALU_input1, Forwarding_2, ALU_input2;
    reg          jump_pc;
    reg  [12:0] ssd_out;
    wire [4:0] MEM_WB_Rd;

    
    // Stage 1
    NBitReg #(N) PC(.clk(clk), .rst(rst), .load(~ID_EX_Ctrl[3]), .D(new_PC) , .Q(cur_PC));
        
    wire [N-1:0] IF_ID_PC, IF_ID_Inst;
    NBitReg #(2 * N) IF_ID(.clk(~clk), .rst(rst), .load(~ID_EX_Ctrl[3]), .D({cur_PC, inst}) , .Q({IF_ID_PC, IF_ID_Inst}));
    
    // Stage 2
    ControlUnit control_unit(.opcode(IF_ID_Inst[`IR_opcode]), .inst20(IF_ID_Inst[20]),
                             .mem_read(mem_read), .mem_to_reg(mem_to_reg), .mem_write(mem_write), .ALU_src(ALU_src), .reg_write(reg_write),
                             .branch(branch), .jal(jal), .jalr(jalr), .auipc(auipc), .freeze_pc(freeze_pc), .zero_pc(zero_pc),
                             .ALU_op(ALU_op));

    RegFile reg_file(.clk(~clk), .rst(rst), .reg_write(MEM_WB_Ctrl[3]), 
                     .rs1(IF_ID_Inst[`IR_rs1]), .rs2(IF_ID_Inst[`IR_rs2]), .rd(MEM_WB_Rd), 
                     .write_data(write_data), .read_data1(read_data1), .read_data2(read_data2));
                     
    ImmGen imm_gen(.IR(IF_ID_Inst), .Imm(imm));
    
    wire [N-1:0] ID_EX_PC, ID_EX_RegR1, ID_EX_RegR2, ID_EX_Imm;
    wire [12:0] ID_EX_Ctrl;
    wire [5:0] ID_EX_Func; // inst[30], inst[25], inst[14:12], inst[5]
    wire [4:0] ID_EX_Rs1, ID_EX_Rs2, ID_EX_Rd;
    
    wire [12:0] control_signals;
    assign control_signals = jump_pc ? 0 : {mem_to_reg, reg_write,auipc,
                             jalr, jal, zero_pc, mem_write, mem_read, branch, 
                             freeze_pc, ALU_src, ALU_op};
    
    NBitReg #(4 * N + 34) ID_EX(.clk(clk), .rst(rst), .load(1'b1), 
                                .D({control_signals, IF_ID_PC, read_data1, read_data2, imm, 
                                    IF_ID_Inst[30], IF_ID_Inst[25], IF_ID_Inst[`IR_funct3], IF_ID_Inst[5],
                                    IF_ID_Inst[`IR_rs1], IF_ID_Inst[`IR_rs2], IF_ID_Inst[`IR_rd]}) , 
                                .Q({ID_EX_Ctrl,ID_EX_PC,ID_EX_RegR1,ID_EX_RegR2, ID_EX_Imm, ID_EX_Func, 
                                    ID_EX_Rs1, ID_EX_Rs2,ID_EX_Rd}));
    
    
    // Stage 3
    ALUControlUnit ALU_control(.inst30(ID_EX_Func[5]), .inst25(ID_EX_Func[4]), .func3(ID_EX_Func[3:1]), .inst5(ID_EX_Func[0]), .ALU_op(ID_EX_Ctrl[1:0]), .ALU_sel(ALU_sel));
   
    ForwardingUnit forward0(.MEM_WB_RegWrite(MEM_WB_Ctrl[3]),
                            .ID_EX_RegisterRs1(ID_EX_Rs1), .ID_EX_RegisterRs2(ID_EX_Rs2), .MEM_WB_RegisterRd(MEM_WB_Rd),
                            .forwardA(forwardA) , .forwardB(forwardB));
   
    
    assign ALU_input1 = forwardA ? write_data : ID_EX_RegR1;
    assign Forwarding_2 = forwardB ? write_data : ID_EX_RegR2;
    assign ALU_input2 = (ID_EX_Ctrl[2] ? ID_EX_Imm : Forwarding_2);
    
    ALU ALU0(.a(ALU_input1), .b(ALU_input2), .shamt(ALU_input2[4:0]), .alufn(ALU_sel),
	             .r(ALU_out), .cf(cf), .zf(zf), .vf(vf), .sf(sf));
   
    assign target_PC = ID_EX_PC + ID_EX_Imm;
    
    
   
    wire [N-1:0] EX_MEM_BranchAddOut, EX_MEM_ALU_out, EX_MEM_RegR2, EX_MEM_PC;
    wire [8:0] EX_MEM_Ctrl;
    wire [4:0] EX_MEM_Rd;
    wire [3:0] EX_MEM_ALU_Flags;
    wire [2:0] EX_MEM_Func3;
    NBitReg #(4 * N + 21) EX_MEM(.clk(~clk), .rst(rst), .load(1'b1), 
                                 .D({ID_EX_Ctrl[12:4], target_PC, cf, zf, vf, sf,  ALU_out, Forwarding_2, ID_EX_Rd, ID_EX_Func[3:1],ID_EX_PC}) , 
                                 .Q({EX_MEM_Ctrl, EX_MEM_BranchAddOut, EX_MEM_ALU_Flags, EX_MEM_ALU_out, EX_MEM_RegR2, EX_MEM_Rd, EX_MEM_Func3, EX_MEM_PC}));

    
    // Stage 4
    // Read instruction if clk is 1. Otherwise, it is data memory.
    wire [N-1:0] mem_out;
    Memory memory(.clk(~clk), .MemRead(clk ? 1'b1 : EX_MEM_Ctrl[1]), .MemWrite(clk ? 0 : EX_MEM_Ctrl[2]), .func3(clk ? `F3_Word : EX_MEM_Func3),
                     .addr(clk ? cur_PC : EX_MEM_ALU_out), .data_in(EX_MEM_RegR2), .data_out(mem_out)); 
        
    always@(*) begin
        if (clk)
            inst = mem_out;
        else
            mem_data_out  = mem_out;
    end
    
                     
    BranchUnit branch_unit(.cf(EX_MEM_ALU_Flags[3]), .zf(EX_MEM_ALU_Flags[2]), .vf(EX_MEM_ALU_Flags[1]), .sf(EX_MEM_ALU_Flags[0]), .branch(EX_MEM_Ctrl[0]),
                           .func3(EX_MEM_Func3), .exec_branch(exec_branch));
                           
    always @(*) begin
        if (EX_MEM_Ctrl[3]) begin // zero pc
             new_PC = 32'b0; 
             jump_pc = 1;
        end
        else if (EX_MEM_Ctrl[4] || exec_branch) begin // jal || exec_branch
             new_PC = EX_MEM_BranchAddOut; 
             jump_pc = 1;
        end
        else if (EX_MEM_Ctrl[5]) begin // jalr
             new_PC = EX_MEM_ALU_out; 
             jump_pc = 1;
        end
        else begin
             new_PC = cur_PC + 4;
             jump_pc = 0;
        end
    end
    
    
    wire [N-1:0] MEM_WB_BranchAddOut, MEM_WB_PC, MEM_WB_Mem_out, MEM_WB_ALU_out;
    wire [4:0] MEM_WB_Ctrl;
    NBitReg #(4 * N + 10) MEM_WB(.clk(clk), .rst(rst), .load(1'b1), 
                                 .D({EX_MEM_Ctrl[8:4], EX_MEM_BranchAddOut, EX_MEM_PC, mem_data_out, EX_MEM_ALU_out, EX_MEM_Rd}) , 
                                 .Q({MEM_WB_Ctrl, MEM_WB_BranchAddOut, MEM_WB_PC, MEM_WB_Mem_out, MEM_WB_ALU_out, MEM_WB_Rd}));

    
    // Stage 5                      
    always @(*) begin
        if (MEM_WB_Ctrl[0] || MEM_WB_Ctrl[1]) write_data = MEM_WB_PC + 4; // jal || jalr
        else if (MEM_WB_Ctrl[2]) write_data = MEM_WB_BranchAddOut; // auipc
        else if (MEM_WB_Ctrl[4]) write_data = MEM_WB_Mem_out; // mem_to_reg
        else write_data = MEM_WB_ALU_out;
    end
    
    // Printing to the nexys board
    always @(*) begin
        case (led_sel)
            2'b00: leds = inst[15:0];
            2'b01: leds = inst[31:16];
            2'b10: leds = {branch, mem_read , mem_to_reg, mem_write, ALU_src, reg_write, ALU_op, ALU_sel, zf, exec_branch};
            default: leds = 0;
        endcase
    end
   
    always @(*) begin
        case (ssd_sel)
            4'b0000: ssd_out = cur_PC;
            4'b0001: ssd_out = cur_PC + 4;
            4'b0010: ssd_out = target_PC;
            4'b0011: ssd_out = new_PC;
            4'b0100: ssd_out = read_data1;
            4'b0101: ssd_out = read_data2;
            4'b0110: ssd_out = write_data;
            4'b0111: ssd_out = imm;
//            4'b1000: ssd_out = {imm, 1'b0};
            4'b1001: ssd_out = ALU_input2;
            4'b1010: ssd_out = ALU_out;
            4'b1011: ssd_out = mem_data_out;
            4'b1100: ssd_out = MEM_WB_Rd;
            default: ssd_out = 0;
        endcase
    end

    SevenSegmentDriver ssdriver(.clk(clk_ssd), .num(ssd_out), .Anode(anode), .LED_out(led_out));
  
endmodule

