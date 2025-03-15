`include "src/instr_decode.v"

module instr_decode_tb();

    reg clk;
    reg [31:0] instr;
    wire [5:0] op;
    wire rs1_v;
    wire [4:0] rs1;
    wire rs2_v;
    wire [4:0] rs2;
    wire rd_v;
    wire [4:0] rd;
    wire imm_v;
    wire [31:0] imm;
    wire load_store_instr;

    instr_decode id(
        .clk(clk),
        .instr(instr),
        .op(op),
        .rs1_v(rs1_v),
        .rs1(rs1),
        .rs2_v(rs2_v),
        .rs2(rs2),
        .rd_v(rd_v),
        .rd(rd),
        .imm_v(imm_v),
        .imm(imm),
        .load_store_instr(load_store_instr)
    );

    initial begin
        $dumpfile("instr_decode_tb.vcd");
        $dumpvars();
        clk = 0;

        instr = 32'h3E808093;
        #10;
        $display("op: %h rs1_v: %d rs1: %d rs2_v: %d rs2: %d rd_v: %d rd: %d imm_v: %d imm: %d", op, rs1_v, rs1, rs2_v, rs2, rd_v, rd, imm_v, imm);

        instr = 32'h4B008093;
        #10;
        $display("op: %h rs1_v: %d rs1: %d rs2_v: %d rs2: %d rd_v: %d rd: %d imm_v: %d imm: %d", op, rs1_v, rs1, rs2_v, rs2, rd_v, rd, imm_v, imm);

        instr = 32'h57808093;
        #10;
        $display("op: %h rs1_v: %d rs1: %d rs2_v: %d rs2: %d rd_v: %d rd: %d imm_v: %d imm: %d", op, rs1_v, rs1, rs2_v, rs2, rd_v, rd, imm_v, imm);

        instr = 32'h64008093;
        #10;
        $display("op: %h rs1_v: %d rs1: %d rs2_v: %d rs2: %d rd_v: %d rd: %d imm_v: %d imm: %d", op, rs1_v, rs1, rs2_v, rs2, rd_v, rd, imm_v, imm);
        
        instr = 32'h70808093;
        #10;
        $display("op: %h rs1_v: %d rs1: %d rs2_v: %d rs2: %d rd_v: %d rd: %d imm_v: %d imm: %d", op, rs1_v, rs1, rs2_v, rs2, rd_v, rd, imm_v, imm);

        $finish;
    end

    always begin
        #5 clk = ~clk;
    end

endmodule