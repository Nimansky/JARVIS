`include "src/constants.v"
`include "src/alu.v"

module alu_tb;

    reg clk;
    reg [31:0] a;
    reg [31:0] b;
    reg [5:0] alu_op;
    wire [31:0] result;

    alu alu(
        .clk(clk), 
        .a(a), 
        .b(b), 
        .alu_op(alu_op), 
        .result(result)
    ); 
    
    initial begin
        $dumpfile("alu_tb.vcd");
        $dumpvars();
        clk = 0;

        a = 10;
        b = 20;
        alu_op = `ADD;
        #10;
        $display("alu_op = ADD, a = %d, b = %d, result = %d", a, b, result);

        a = 32'h00000001;
        b = 32'hffffffff;
        alu_op = `SLTU;
        #10;
        $display("alu_op = SLTU, a = %d, b = %d, result = %d", a, b, result);

        a = -32'd1;
        b = -32'd0;
        alu_op = `SLT;
        #10;
        $display("alu_op = SLT, a = %d, b = %d, result = %d", $signed(a), $signed(b), result);

        a = 32'hffffffff;
        b = 32'h00000000;
        alu_op = `AND;
        #10;
        $display("alu_op = AND, a = %h, b = %h, result = %h", a, b, result);

        a = 32'hffffffff;
        b = 32'h00000000;
        alu_op = `OR;
        #10;
        $display("alu_op = OR, a = %h, b = %h, result = %h", a, b, result);

        a = 32'hf0f0f0f0;
        b = 32'h0f0f0f0f;
        alu_op = `XOR;
        #10;
        $display("alu_op = XOR, a = %h, b = %h, result = %h", a, b, result);

        a = -32'd128;
        b = -32'd127;
        alu_op = `SUB;
        #10;
        $display("alu_op = SUB, a = %d, b = %d, result = %d", $signed(a), $signed(b), $signed(result));
        
        a = 32'hffffffff;
        b = 1;
        alu_op = `SLL;
        #10;
        $display("alu_op = SLL, a = %b, b = %b, result = %b", a, b, result);

        a = 32'hffffffff;
        b = 1;
        alu_op = `SRL;
        #10;
        $display("alu_op = SRL, a = %b, b = %b, result = %b", a, b, result);

        a = 32'h80000000;
        b = 1;
        alu_op = `SRA;
        #10;
        $display("alu_op = SRA, a = %b, b = %b, result = %b", a, b, result);

        $finish;
    end

    always begin
        #5 clk = ~clk;
    end

endmodule
