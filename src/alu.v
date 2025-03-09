`include "src/constants.v"

module alu
(
    input clk,
    input [31:0] a,
    input [31:0] b,
    input [5:0] alu_op,
    output reg [31:0] result
);

always @ (posedge clk) begin
    case (alu_op)
        `ADDI,
        `ADD: result <= a + b;
        `SLTIU,
        `SLTU: result <= (a < b) ? 1 : 0;
        `SLT,
        `SLTI: result <= ($signed(a) < $signed(b)) ? 1 : 0;
        `ANDI,
        `AND: result <= a & b;
        `ORI,
        `OR: result <= a | b;
        `XORI,
        `XOR: result <= a ^ b;
        `SUB: result <= a - b;
        `SLL,
        `SLLI: result <= a << b[4:0];
        `SRL,
        `SRLI: result <= a >> b[4:0];
        `SRA,
        `SRAI: result <= {a[31], a[31:1]};
        default: result <= 0;
    endcase
end

endmodule
