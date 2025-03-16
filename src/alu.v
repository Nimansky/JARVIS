`include "src/constants.v"

module alu
(
    input [31:0] a,
    input [31:0] b,
    input [5:0] alu_op,
    output [31:0] result,
    output a_less_b
);

reg [31:0] alu_out;

always @ (*) begin
    case (alu_op)
        `ADDI,
        `ADD,
        `LOAD,
        `STORE: alu_out = a + b;
        `SLTIU,
        `SLTU: alu_out = (a < b) ? 1 : 0;
        `SLT,
        `SLTI: alu_out = ($signed(a) < $signed(b)) ? 1 : 0;
        `ANDI,
        `AND: alu_out = a & b;
        `ORI,
        `OR: alu_out = a | b;
        `XORI,
        `XOR: alu_out = a ^ b;
        `SUB: alu_out = a - b;
        `SLL,
        `SLLI: alu_out = a << b[4:0];
        `SRL,
        `SRLI: alu_out = a >> b[4:0];
        `SRA,
        `SRAI: alu_out = {a[31], a[31:1]};
        `BEQ: alu_out = (a == b) ? 1 : 0;
        `BNE: alu_out = (a != b) ? 1 : 0;
        `BLT: alu_out = ($signed(a) < $signed(b)) ? 1 : 0;
        `BLTU: alu_out = (a < b) ? 1 : 0;
        `BGE: alu_out = ($signed(a) >= $signed(b)) ? 1 : 0;
        `BGEU: alu_out = (a >= b) ? 1 : 0;
        default: alu_out = 0;
    endcase
end

assign result = alu_out;

endmodule
