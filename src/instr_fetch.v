`include "src/mux.v"
`include "src/pc_module.v"
`include "src/pc_adder.v"

module instr_fetch(
    input clk,
    input reset,
    input flush,
    input stall,
    input [31:0] pc_target_exec,
    input pc_src_exec,

    // signals for external memory interface
    output wire [31:0] memreq_addr,
    output wire memreq_ready,
    input wire [31:0] memresp_data_in,
    input wire memresp_valid,

    output wire [31:0] instr_decode,
    output wire [31:0] pc_decode, next_pc_decode,
    output wire valid
);


    // intermediate wires
    wire [31:0] muxed_pc, pc, next_pc;
    wire [31:0] fetched_instr;

    mux pc_mux(
        .a(next_pc),
        .b(pc_target_exec),
        .sel(pc_src_exec),
        .out(muxed_pc)
    );

    pc_module pc_module(
        .clk(clk),
        .next_pc(muxed_pc),
        .pc(pc)
    );

    assign memreq_addr = pc;
    assign memreq_ready = !stall;   // request instruction mem fetch when not stalled
    assign fetched_instr = memresp_data_in;

    pc_adder pc_adder(
        .a(pc),
        .b(4),
        .out(next_pc)
    );

    // pipeline registers
    reg [31:0] fetched_instr_reg;
    reg [31:0] pc_reg;
    reg [31:0] next_pc_reg;
    reg valid_reg;

    always @ (posedge clk or negedge reset) begin
        if (flush == 1'b1 || reset == 1'b0) begin
            fetched_instr_reg <= 32'h00000000;
            pc_reg <= 32'h00000000;
            next_pc_reg <= 32'h00000000;
            valid_reg <= 1'b0;
        end else if (!stall) begin
            fetched_instr_reg <= fetched_instr;
            pc_reg <= pc;
            next_pc_reg <= next_pc;
            valid_reg <= 1'b1;
        end
    end

    // assign pipeline registers to outputs
    assign instr_decode = fetched_instr_reg;
    assign pc_decode = pc_reg;
    assign next_pc_decode = next_pc_reg;
    assign valid = valid_reg;

endmodule