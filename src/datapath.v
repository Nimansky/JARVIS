`include "src/instr_fetch.v"
`include "src/instr_decode.v"
`include "src/regfile.v"
`include "src/exec.v"
`include "src/memacc.v"

module datapath (
    input clk,
    output reg [31:0] out
);

    // concept for all stages:
    // wire for all outputs
    // store results in regs at each posedge clk

    wire [31:0] fetch_to_decode_pc, fetch_to_decode_next_pc, fetch_to_decode_instr;

    instr_fetch instr_fetch(
        .clk(clk),
        .pc_target_exec(),          // needs input from exec
        .pc_src_exec(1),            // 1 means PC should be incremented by 4 - needs output from exec
        .instr_decode(fetch_to_decode_instr),
        .pc_decode(fetch_to_decode_pc),
        .next_pc_decode(fetch_to_decode_next_pc)
    );

    wire [31:0] decode_to_exec_pc, decode_to_exec_next_pc;
    wire decode_to_exec_rd_write_enable, decode_to_exec_res_src, decode_to_exec_branch, decode_to_exec_alu_input_conf;
    wire [5:0] decode_to_exec_alu_op;
    wire [31:0] decode_to_exec_imm, decode_to_exec_rs1_data, decode_to_exec_rs2_data;
    wire [4:0] decode_to_exec_rd_write;

    instr_decode decode(
        .clk(clk),
        .instr(fetch_to_decode_instr),
        .pc_in(fetch_to_decode_pc),
        .next_pc_in(fetch_to_decode_next_pc),
        .reg_write_data(0),     // TODO: connect to writeback stage
        .reg_write_enable(0),   // TODO: connect to writeback stage
        .reg_write_addr(0),     // TODO: connect to writeback stage
        .pc_out(decode_to_exec_pc),
        .next_pc_out(decode_to_exec_next_pc),
        .rd_write_enable(decode_to_exec_rd_write_enable),
        .rd_write_addr(decode_to_exec_rd_write),
        .res_src(decode_to_exec_res_src),
        .branch(decode_to_exec_branch),
        .alu_op(decode_to_exec_alu_op),
        .alu_input_conf(decode_to_exec_alu_input_conf),
        .imm(decode_to_exec_imm),
        .rs1_data(decode_to_exec_rs1_data),
        .rs2_data(decode_to_exec_rs2_data)
    );
    
    wire [31:0] exec_out;

    exec exec(
        .clk(clk),
        .op(decode_to_exec_op),
        .in1(exec_in1),
        .in2(exec_in2),
        .out(exec_out)
    );

    reg [31:0] exec_to_memacc_out;

    always @ (posedge clk) begin
        exec_to_memacc_out <= exec_out;
    end


    wire memacc_data_out_v;
    wire [31:0] memacc_data_out;

    memacc memacc(
        .clk(clk),
        .enable(decode_to_memacc_load_store_instr),     // disable the memory access unit if it's not a load/store
        .addr(exec_to_memacc_out),       // ALU should have computed rs1 + imm for Load/Store instructions
        .write_enable(decode_to_regfile_rs2_v),    // it's a store instruction if it's a load/store AND rs2 is valid (bc loads dont have rs2)
        .data_in(regfile_to_exec_rs2_data),         // IFF it's a store, then the data to be stored is the value of rs2
        .data_out_v(memacc_data_out_v),
        .data_out(memacc_data_out)
    );

    reg memacc_to_writeback_data_out_v;
    reg [31:0] memacc_to_writeback_data_out;

    always @ (posedge clk) begin
        memacc_to_writeback_data_out <= memacc_data_out_v ? memacc_data_out : exec_to_memacc_out;
    end


    // TODO: writeback stage here

    assign writeback_write_enable = decode_to_writeback_rd_v;
    assign writeback_write_addr = decode_to_writeback_rd;
    assign writeback_data_in = memacc_to_writeback_data_out;


    // memacc is last stage as of now (WB stage not implemented yet)
    always @ (posedge clk) begin
        out <= memacc_to_writeback_data_out_v ? memacc_to_writeback_data_out : exec_to_memacc_out;
    end


    // new instruction each cycle (no abort condition yet, no branch support yet)
    always @ (posedge clk) begin
        pc <= pc + 4;
    end

endmodule