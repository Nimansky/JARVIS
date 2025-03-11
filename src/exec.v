`include "src/constants.v"
`include "src/alu.v"

module exec(
    input clk,
    input [5:0] op,
    input [31:0] in1,
    input [31:0] in2,

    output reg [31:0] out
);

    wire [31:0] res_alu;

    alu alu(
        .clk(clk),
        .a(in1),
        .b(in2),
        .alu_op(op),
        .result(res_alu)
    );

    always @ (*) begin
        case (op)
            `ADDI,
            `ADD,
            `SLTIU,
            `SLTU,
            `SLT,
            `SLTI,
            `ANDI,
            `AND,
            `ORI,
            `OR,
            `XORI,
            `XOR,
            `SUB,
            `SLL,
            `SLLI,
            `SRL,
            `SRLI,
            `SRA,
            `SRAI: begin
                out = res_alu;
            end
            default: out = 0;
        endcase
    end

endmodule