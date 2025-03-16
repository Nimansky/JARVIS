`include "src/constants.v"
`include "src/alu.v"
`include "src/mux.v"
`include "src/pc_adder.v"

module exec(
    input clk,

    input [5:0] alu_op,
    input [31:0] pc_in, 
    input [31:0] next_pc_in,
    input rd_write_enable,
    input [4:0] rd_write_addr, 
    input [1:0] res_src, 
    input branch, 
    input jump, 
    input mem_write_enable,
    input alu_input_conf,
    input [31:0] imm, 
    input [31:0] rs1_data, 
    input [31:0] rs2_data,

    output [31:0] target_pc,
    output pc_src,

    output rd_write_enable_out,
    output [4:0] rd_write_addr_out,
    output [1:0] res_src_out,
    output mem_write_enable_out,
    output [31:0] exec_out,
    output [31:0] mem_write_data_out,
    output [31:0] next_pc_out
);


    // intermediate wires
    wire [31:0] res_alu, in2, adder_in, tgt_plus_offset;
    wire a_less_b;

    mux in2_mux(
        .a(imm),
        .b(rs2_data),
        .sel(alu_input_conf),
        .out(in2)
    );

    alu alu(
        .a(rs1_data),
        .b(in2),
        .alu_op(alu_op),
        .result(res_alu),
        .a_less_b(a_less_b)
    );

    mux adder_in_mux(       // JALR jumps to rs1 + imm, all other jumps/branches to PC + imm => MUX to select between rs1 and PC
        .a(pc_in),
        .b(rs1_data),
        .sel(alu_op == `JALR),
        .out(adder_in)
    );

    pc_adder pc_adder(
        .a(adder_in),
        .b(imm),
        .out(tgt_plus_offset)
    );

    reg [31:0] out;
    always @ (*) begin
        case (alu_op)
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

    assign pc_src = jump || (branch && res_alu[0]) ? 1 : 0;
    assign target_pc = tgt_plus_offset; 

    // pipeline registers
    reg rd_write_enable_reg;
    reg [4:0] rd_write_addr_reg;
    reg [1:0] res_src_reg;
    reg mem_write_enable_reg;
    reg [31:0] exec_out_reg;
    reg [31:0] mem_write_data_reg;
    reg [31:0] next_pc_reg;

    always @ (posedge clk) begin
        rd_write_enable_reg <= rd_write_enable;
        rd_write_addr_reg <= rd_write_addr;
        res_src_reg <= res_src;
        mem_write_enable_reg <= mem_write_enable;

        exec_out_reg <= out;
        mem_write_data_reg <= rs2_data;
        next_pc_reg <= next_pc_in;
    end

    assign rd_write_enable_out = rd_write_enable_reg;
    assign rd_write_addr_out = rd_write_addr_reg;
    assign res_src_out = res_src_reg;
    assign mem_write_enable_out = mem_write_enable_reg;
    assign exec_out = exec_out_reg;
    assign mem_write_data_out = mem_write_data_reg;
    assign next_pc_out = next_pc_reg;

endmodule