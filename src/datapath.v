`include "src/instr_fetch.v"
`include "src/instr_decode.v"
`include "src/regfile.v"
`include "src/exec.v"
`include "src/memacc.v"

module datapath (
    input clk,
    output reg [31:0] out
);

    reg [31:0] pc = 0;

    // concept for all stages:
    // wire for all outputs
    // store results in regs at each posedge clk

    wire [31:0] fetch_instr_out;

    instr_fetch instr_fetch(
        .clk(clk),
        .pc(pc),
        .instr_out(fetch_instr_out)
    );

    reg [31:0] fetch_to_decode_instr_out;

    always @ (posedge clk) begin
        fetch_to_decode_instr_out <= fetch_instr_out;
    end

    wire [5:0] decode_op;
    wire decode_rs1_v;
    wire [4:0] decode_rs1;
    wire decode_rs2_v;
    wire [4:0] decode_rs2;
    wire [4:0] decode_rd;
    wire decode_imm_v;
    wire [31:0] decode_imm;
    wire decode_load_store_instr;

    instr_decode instr_decode(
        .clk(clk),
        .instr(fetch_to_decode_instr_out),
        .op(decode_op),
        .rs1_v(decode_rs1_v),
        .rs1(decode_rs1),
        .rs2_v(decode_rs2_v),
        .rs2(decode_rs2),
        .rd(decode_rd), 
        .imm_v(decode_imm_v),
        .imm(decode_imm),
        .load_store_instr(decode_load_store_instr)
    );

    reg [5:0] decode_to_exec_op;
    reg decode_to_regfile_rs1_v;
    reg [4:0] decode_to_regfile_rs1;
    reg decode_to_regfile_rs2_v;
    reg [4:0] decode_to_regfile_rs2;
    reg [4:0] decode_to_exec_rd;
    reg decode_to_exec_imm_v;
    reg [31:0] decode_to_exec_imm;
    reg decode_to_memacc_load_store_instr;


    // additional logic in decode stage: access regfile and read values if necessary
    wire [31:0] regfile_to_exec_rs1_data;
    wire [31:0] regfile_to_exec_rs2_data;

    regfile rf(
        .clk(clk),
        .read_addr1(decode_to_regfile_rs1),
        .read_addr2(decode_to_regfile_rs2),
        .data_in(),         // later driven by WRITEBACK unit
        .write_enable(),    // later driven by WRITEBACK unit
        .write_addr(),      // later driven by WRITEBACK unit
        .data_out1(regfile_to_exec_rs1_data),
        .data_out2(regfile_to_exec_rs2_data)
    );

    reg [31:0] exec_in1;
    reg [31:0] exec_in2;

    always @ (posedge clk) begin
        decode_to_exec_op = decode_op;
        decode_to_regfile_rs1_v = decode_rs1_v;
        decode_to_regfile_rs1 = decode_rs1;
        decode_to_regfile_rs2_v = decode_rs2_v;
        decode_to_regfile_rs2 = decode_rs2;
        decode_to_exec_rd = decode_rd;
        decode_to_exec_imm_v = decode_imm_v;
        decode_to_exec_imm = decode_imm;
        decode_to_memacc_load_store_instr = decode_load_store_instr;
    end


    // conditional assignment of exec unit inputs; either reg values or immediate values
    always @ (*) begin
        if (decode_to_regfile_rs1_v && decode_to_regfile_rs2_v) begin
            exec_in1 = regfile_to_exec_rs1_data;
            exec_in2 = regfile_to_exec_rs2_data;
        end else if (decode_to_regfile_rs1_v && decode_to_exec_imm_v) begin
            exec_in1 = regfile_to_exec_rs1_data;
            exec_in2 = decode_to_exec_imm;
        end else if (decode_to_regfile_rs2_v && decode_to_exec_imm_v) begin
            exec_in1 = regfile_to_exec_rs2_data;
            exec_in2 = decode_to_exec_imm;
        end else begin
            exec_in1 = 0;
            exec_in2 = 0;
        end
    end
    
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
        memacc_to_writeback_data_out_v <= memacc_data_out_v;
        memacc_to_writeback_data_out <= memacc_data_out;
    end


    // TODO: writeback stage here


    // memacc is last stage as of now (WB stage not implemented yet)
    always @ (posedge clk) begin
        out <= memacc_to_writeback_data_out_v ? memacc_to_writeback_data_out : exec_to_memacc_out;
    end


    // new instruction each cycle (no abort condition yet, no branch support yet)
    always @ (posedge clk) begin
        pc <= pc + 4;
    end

endmodule