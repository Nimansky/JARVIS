`include "src/constants.v"
`include "src/exec.v"

module exec_tb();

    reg clk;
    reg [5:0] op;
    reg [31:0] in1;
    reg [31:0] in2;

    wire rd_write_enable, res_src, mem_write_enable;
    wire [4:0] rd_write_addr;
    wire [31:0] out;
    wire [31:0] mem_write_data_out;
    wire [31:0] next_pc;

    exec exec(
        .clk(clk),
        .alu_op(op),
        .pc_in(0),
        .next_pc_in(0),
        .rd_write_enable(0),
        .rd_write_addr(0),
        .res_src(0),
        .branch(0),
        .jump(0),
        .mem_write_enable(0),
        .alu_input_conf(1'b1),     // i.e. rs1 and rs2 (not imm)
        .imm(0),
        .rs1_data(in1),
        .rs2_data(in2),

        .target_pc(),
        .pc_src(),

        .rd_write_enable_out(rd_write_enable),
        .rd_write_addr_out(rd_write_addr),
        .res_src_out(res_src),
        .mem_write_enable_out(mem_write_enable),
        .exec_out(out),
        .mem_write_data_out(mem_write_data_out),
        .next_pc_out(next_pc)
    );

    initial begin
        $dumpfile("exec_tb.vcd");
        $dumpvars();
        clk = 0;

        // ADD
        op = `ADD;
        in1 = 32'h00000001;
        in2 = 32'h00000002;
        #10;
        $display("op: %b, in1: %h, in2: %h, res: %h", op, in1, in2, out);

        $finish;
    end

    always begin
        #5 clk = ~clk;
    end

endmodule;