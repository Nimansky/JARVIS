`include "src/constants.v"
`include "src/exec.v"

module exec_tb();

    reg clk;
    reg [5:0] op;
    reg [31:0] in1;
    reg [31:0] in2;
    wire [31:0] out;

    exec exec(
        .clk(clk),
        .op(op),
        .in1(in1),
        .in2(in2),
        .out(out)
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