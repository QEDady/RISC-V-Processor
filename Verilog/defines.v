`define     IR_rs1          19:15
`define     IR_rs2          24:20
`define     IR_rd           11:7
`define     IR_opcode       6:2
`define     IR_funct3       14:12
`define     IR_funct7       31:25
`define     IR_shamt        24:20

`define     OPCODE_Branch   5'b11_000
`define     OPCODE_Load     5'b00_000
`define     OPCODE_Store    5'b01_000
`define     OPCODE_JALR     5'b11_001
`define     OPCODE_JAL      5'b11_011
`define     OPCODE_Arith_I  5'b00_100
`define     OPCODE_Arith_R  5'b01_100
`define     OPCODE_AUIPC    5'b00_101
`define     OPCODE_LUI      5'b01_101
`define     OPCODE_SYSTEM   5'b11_100 
`define     OPCODE_FENCE    5'b000_11 
`define     OPCODE_Custom   5'b10_001

`define     F3_ADD          3'b000
`define     F3_SLL          3'b001
`define     F3_SLT          3'b010
`define     F3_SLTU         3'b011
`define     F3_XOR          3'b100
`define     F3_SRL          3'b101
`define     F3_OR           3'b110
`define     F3_AND          3'b111

`define     F3_MUL          3'b000
`define     F3_MULH         3'b001
`define     F3_MULHSU       3'b010
`define     F3_MULHU        3'b011
`define     F3_DIV          3'b100
`define     F3_DIVU         3'b101
`define     F3_REM          3'b110
`define     F3_REMU         3'b111

`define     F3_Byte         3'b000
`define     F3_Half         3'b001
`define     F3_Word         3'b010
`define     F3_ByteU        3'b100
`define     F3_HalfU        3'b101

`define     BR_BEQ          3'b000
`define     BR_BNE          3'b001
`define     BR_BLT          3'b100
`define     BR_BGE          3'b101
`define     BR_BLTU         3'b110
`define     BR_BGEU         3'b111

`define     OPCODE          IR[`IR_opcode]

`define     ALU_ADD         5'b000_00
`define     ALU_SUB         5'b000_01
`define     ALU_PASS        5'b000_11
`define     ALU_OR          5'b001_00
`define     ALU_AND         5'b001_01
`define     ALU_XOR         5'b001_11
`define     ALU_SRL         5'b010_00
`define     ALU_SRA         5'b010_10
`define     ALU_SLL         5'b010_01
`define     ALU_SLT         5'b011_01
`define     ALU_SLTU        5'b011_11
`define     ALU_MUL         5'b100_00
`define     ALU_MULH        5'b100_01
`define     ALU_MULHSU      5'b100_10
`define     ALU_MULHU       5'b100_11
`define     ALU_DIV         5'b101_00
`define     ALU_DIVU        5'b101_01
`define     ALU_REM         5'b101_10
`define     ALU_REMU        5'b101_11

`define     SYS_EC_EB       3'b000

