`include "src/instr_mem.v"

module instr_fetch(
    input clk,
    input [31:0] pc,
    output [31:0] instr_out
);

    // for now nothing needs to be done besides fetching an instruction
    instr_mem #(.PROG_NAME("sample_prog0")) im (
        .clk(clk),
        .addr(pc),
        .data_out(instr_out)
    );

endmodule