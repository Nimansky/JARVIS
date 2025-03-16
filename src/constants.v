`ifndef CONSTANTS
`define CONSTANTS
`define ADDI 6'b000000
`define SLTI 6'b000001
`define SLTIU 6'b000010
`define ANDI 6'b000011
`define ORI 6'b000100
`define XORI 6'b000101
`define SLLI 6'b000110
`define SRLI 6'b000111
`define SRAI 6'b001000
`define LUI 6'b001001
`define AUIPC 6'b001010
`define ADD 6'b001011
`define SLT 6'b001100
`define SLTU 6'b001101
`define AND 6'b001110
`define OR 6'b001111
`define XOR 6'b010000
`define SLL 6'b010001
`define SRL 6'b010010
`define SUB 6'b010011
`define SRA 6'b010100
`define NOP 6'b010101
`define JAL 6'b010110
`define JALR 6'b010111
`define BEQ 6'b011000
`define BNE 6'b011001
`define BLT 6'b011010
`define BLTU 6'b011011
`define BGE 6'b011100
`define BGEU 6'b011101
`define FENCE 6'b011110
`define ECALL 6'b011111
`define EBREAK 6'b100000
`define LOAD 6'b100001
`define STORE 6'b100010

// memory widths (correspond to funct3 bits of load/store instructions)
`define BYTE 3'b000
`define HWORD 3'b001
`define WORD 3'b010
`define BYTEU 3'b100
`define HWORDU 3'b101

// backup
// `define LB 6'b100001
// `define LH 6'b100010
// `define LW 6'b100011
// `define LBU 6'b100100
// `define LHU 6'b100101
// `define SB 6'b100110
// `define SH 6'b100111
// `define SW 6'b101000
`endif
