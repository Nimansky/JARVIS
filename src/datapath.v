`include "src/instr_fetch.v"
`include "src/instr_decode.v"
`include "src/exec.v"
`include "src/memacc.v"
`include "src/writeback.v"

module datapath (
    input clk,
    output reg [31:0] out
);

    // concept for all stages:
    // wire for all outputs
    // store results in regs at each posedge clk

    wire [31:0] fetch_to_decode_pc, fetch_to_decode_next_pc, fetch_to_decode_instr;

    wire [31:0] exec_to_fetch_target_pc;        // fed back from exec stage
    wire exec_to_fetch_pc_src;                  // fed back from exec stage

    instr_fetch instr_fetch(
        .clk(clk),
        .pc_target_exec(exec_to_fetch_target_pc),  
        .pc_src_exec(exec_to_fetch_pc_src),            // 0 means PC should be incremented by 4 - needs output from exec
        .instr_decode(fetch_to_decode_instr),
        .pc_decode(fetch_to_decode_pc),
        .next_pc_decode(fetch_to_decode_next_pc)
    );

    wire [31:0] decode_to_exec_pc, decode_to_exec_next_pc;
    wire [1:0] decode_to_exec_res_src;
    wire decode_to_exec_rd_write_enable, decode_to_exec_branch, decode_to_exec_jump, decode_to_exec_mem_write_enable, decode_to_exec_alu_input_conf;
    wire [5:0] decode_to_exec_alu_op;
    wire [31:0] decode_to_exec_imm, decode_to_exec_rs1_data, decode_to_exec_rs2_data;
    wire [4:0] decode_to_exec_rd_write_addr;
    wire [2:0] decode_to_exec_mem_width;

    wire [31:0] writeback_to_decode_data_out; // fed back from writeback stage
    wire writeback_to_decode_write_enable; // fed back from writeback stage
    wire [4:0] writeback_to_decode_write_addr; // fed back from writeback stage

    instr_decode decode(
        .clk(clk),
        .instr(fetch_to_decode_instr),
        .pc_in(fetch_to_decode_pc),
        .next_pc_in(fetch_to_decode_next_pc),
        .reg_write_data(writeback_to_decode_data_out),     
        .reg_write_enable(writeback_to_decode_write_enable),
        .reg_write_addr(writeback_to_decode_write_addr),
        .pc_out(decode_to_exec_pc),
        .next_pc_out(decode_to_exec_next_pc),
        .rd_write_enable(decode_to_exec_rd_write_enable),
        .rd_write_addr(decode_to_exec_rd_write_addr),
        .res_src(decode_to_exec_res_src),
        .branch(decode_to_exec_branch),
        .jump(decode_to_exec_jump),
        .mem_width_out(decode_to_exec_mem_width),
        .mem_write_enable(decode_to_exec_mem_write_enable),
        .alu_op(decode_to_exec_alu_op),
        .alu_input_conf(decode_to_exec_alu_input_conf),
        .imm(decode_to_exec_imm),
        .rs1_data(decode_to_exec_rs1_data),
        .rs2_data(decode_to_exec_rs2_data)
    );
    
    wire [1:0] exec_to_memacc_res_src;
    wire exec_to_memacc_rd_write_enable, exec_to_memacc_mem_write_enable;
    wire [4:0] exec_to_memacc_rd_write_addr;
    wire [31:0] exec_to_memacc_data_out;
    wire [31:0] exec_to_memacc_mem_write_data_out;
    wire [31:0] exec_to_memacc_next_pc;
    wire [2:0] exec_to_memacc_mem_width;

    exec exec(
        .clk(clk),
        .alu_op(decode_to_exec_alu_op),
        .pc_in(decode_to_exec_pc),
        .next_pc_in(decode_to_exec_next_pc),
        .rd_write_enable(decode_to_exec_rd_write_enable),
        .rd_write_addr(decode_to_exec_rd_write_addr),
        .res_src(decode_to_exec_res_src),
        .branch(decode_to_exec_branch),
        .jump(decode_to_exec_jump),
        .mem_write_enable(decode_to_exec_mem_write_enable),
        .mem_width_in(decode_to_exec_mem_width),
        .alu_input_conf(decode_to_exec_alu_input_conf),
        .imm(decode_to_exec_imm),
        .rs1_data(decode_to_exec_rs1_data),
        .rs2_data(decode_to_exec_rs2_data),

        .target_pc(exec_to_fetch_target_pc),
        .pc_src(exec_to_fetch_pc_src),

        .rd_write_enable_out(exec_to_memacc_rd_write_enable),
        .rd_write_addr_out(exec_to_memacc_rd_write_addr),
        .res_src_out(exec_to_memacc_res_src),
        .mem_write_enable_out(exec_to_memacc_mem_write_enable),
        .mem_width_out(exec_to_memacc_mem_width),
        .exec_out(exec_to_memacc_data_out),
        .mem_write_data_out(exec_to_memacc_mem_write_data_out),
        .next_pc_out(exec_to_memacc_next_pc)
    );

    wire [31:0] memacc_to_wb_exec_data_out, memacc_to_wb_mem_data_out, memacc_to_wb_next_pc;
    wire [1:0] memacc_to_wb_res_src;

    memacc memacc(
        .clk(clk),
        .next_pc_in(exec_to_memacc_next_pc),
        .rd_write_enable_in(exec_to_memacc_rd_write_enable),
        .rd_write_addr_in(exec_to_memacc_rd_write_addr),
        .res_src_in(exec_to_memacc_res_src),
        .exec_data_in(exec_to_memacc_data_out),
        .mem_write_enable(exec_to_memacc_mem_write_enable),
        .mem_write_data(exec_to_memacc_mem_write_data_out),
        .mem_width(exec_to_memacc_mem_width),
        .exec_data_out(memacc_to_wb_exec_data_out),
        .mem_data_out(memacc_to_wb_mem_data_out),
        .next_pc_out(memacc_to_wb_next_pc),
        .rd_write_enable_out(writeback_to_decode_write_enable),
        .rd_write_addr_out(writeback_to_decode_write_addr),
        .res_src_out(memacc_to_wb_res_src)
    );


    writeback writeback(
        .clk(clk),
        .exec_data_in(memacc_to_wb_exec_data_out),
        .mem_data_in(memacc_to_wb_mem_data_out),
        .next_pc(memacc_to_wb_next_pc),
        .res_src(memacc_to_wb_res_src),
        .data_out(writeback_to_decode_data_out)
    );



endmodule