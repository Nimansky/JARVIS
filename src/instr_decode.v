`include "src/constants.v"
`include "src/decode_control_unit.v"
`include "src/imm_extender.v"
`include "src/regfile.v"

module instr_decode(
    input clk,
    input [31:0] instr,
    input [31:0] pc_in,
    input [31:0] next_pc_in,

    input [31:0] reg_write_data,
    input reg_write_enable,
    input [4:0] reg_write_addr,

    output [31:0] pc_out,
    output [31:0] next_pc_out,
    output rd_write_enable,
    output [1:0] res_src,
    output branch,
    output jump,
    output mem_write_enable,
    output [2:0] mem_width_out,
    output [5:0] alu_op,
    output alu_input_conf,
    output [31:0] imm,
    output [31:0] rs1_data,
    output [31:0] rs2_data,
    output [4:0] rd_write_addr
);

    // intermediate wires
    wire rd_write_en;
    wire [1:0] result_src;
    wire is_branch;
    wire is_jump;
    wire mem_w_en;
    wire [2:0] mem_width;
    wire [5:0] op;
    wire alu_input_config;
    wire [2:0] imm_sel;

    wire [31:0] rs1_d;
    wire [31:0] rs2_d;

    wire [31:0] imm_v;

    decode_control_unit dcu(
        .instr(instr),
        .reg_write_enable(rd_write_en),
        .result_src(result_src),
        .is_branch(is_branch),
        .is_jump(is_jump),
        .mem_write_enable(mem_w_en),
        .mem_width(mem_width),
        .alu_op(op),
        .alu_input_config(alu_input_config),
        .imm_sel(imm_sel)
    );



    regfile rf(
        .clk(clk),
        .read_addr1(instr[19:15]),
        .read_addr2(instr[24:20]),
        .data_in(reg_write_data),         // later driven by WRITEBACK unit
        .write_enable(reg_write_enable),    // later driven by WRITEBACK unit
        .write_addr(reg_write_addr),      // later driven by WRITEBACK unit
        .data_out1(rs1_d),
        .data_out2(rs2_d)
    );



    imm_extender ex(
        .in(instr[31:0]),
        .imm_sel(imm_sel),
        .out(imm_v)
    );


    // pipeline registers

    reg rd_write_enable_reg;
    reg [4:0] rd_write_addr_reg;
    reg [1:0] res_src_reg;
    reg branch_reg;
    reg jump_reg;
    reg mem_write_enable_reg;
    reg [2:0] mem_width_out_reg;
    reg [5:0] alu_op_reg;
    reg alu_input_conf_reg;
    reg [31:0] imm_reg;
    reg [31:0] rs1_data_reg;
    reg [31:0] rs2_data_reg;
    reg [31:0] pc_reg;
    reg [31:0] next_pc_reg;

    always @ (posedge clk) begin
        rd_write_enable_reg <= rd_write_en;
        rd_write_addr_reg <= instr[11:7];
        res_src_reg <= result_src;
        branch_reg <= is_branch;
        jump_reg <= is_jump;
        mem_write_enable_reg <= mem_w_en;
        mem_width_out_reg <= mem_width;
        alu_op_reg <= op;
        alu_input_conf_reg <= alu_input_config;
        imm_reg <= imm_v;
        rs1_data_reg <= rs1_d;
        rs2_data_reg <= rs2_d;
        pc_reg <= pc_in;
        next_pc_reg <= next_pc_in;
    end

    assign pc_out = pc_reg;
    assign next_pc_out = next_pc_reg;
    assign rd_write_enable = rd_write_enable_reg;
    assign rd_write_addr = rd_write_addr_reg;
    assign res_src = res_src_reg;
    assign branch = branch_reg;
    assign jump = jump_reg;
    assign mem_write_enable = mem_write_enable_reg;
    assign mem_width_out = mem_width_out_reg;
    assign alu_op = alu_op_reg;
    assign alu_input_conf = alu_input_conf_reg;
    assign imm = imm_reg;
    assign rs1_data = rs1_data_reg;
    assign rs2_data = rs2_data_reg;

endmodule;