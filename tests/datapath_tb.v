`include "src/datapath.v"

module datapath_tb();

    reg clk;
    wire [31:0] out;

    datapath datapath(
        .clk(clk),
        .out(out)
    );

    initial begin
        $dumpfile("datapath_tb.vcd");
        $dumpvars();
        clk = 0;

        #10;
        $display("out: %h", out);       // 0
        #10;
        $display("out: %h", out);        // 0
        #10;
        $display("out: %h", out);      // 0  
        #10;
        $display("out: %h", out);       // first instruction should return here 
        #10;
        $display("out: %h", out);        // second instr
        #10;
        $display("out: %h", out);        // third instr
        #10;
        $display("out: %h", out);       // fourth instr
        #10;
        $display("out: %h", out);       // fifth instr
        #10;
        $display("out: %h", out);       // there is no sixth instr, therefore same as before
        #10;
        $display("out: %h", out);       // there is no seventh instr, therefore same as before

        $finish;
    end

    always begin
        #5 clk = ~clk;
    end
endmodule