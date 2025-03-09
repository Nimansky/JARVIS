`include "src/instr_fetch.v"

module instr_fetch_tb();

    reg clk;
    reg [31:0] addr;
    wire [31:0] data_out;

    instr_fetch instr_fetch (
        .clk(clk),
        .pc(addr),
        .instr_out(data_out)
    );

    initial begin
        $dumpfile("dump.vcd");
        $dumpvars();
        clk = 0;

        addr = 0;
        #10;
        $display("addr = %h, data_out = %h", addr, data_out);

        addr = 32'h00000001;
        #10;
        $display("addr = %h, data_out = %h", addr, data_out);

        addr = 32'h00000002;
        #10;
        $display("addr = %h, data_out = %h", addr, data_out);

        addr = 32'h00000003;
        #10;
        $display("addr = %h, data_out = %h", addr, data_out);

        addr = 32'h00000004;
        #10;
        $display("addr = %h, data_out = %h", addr, data_out);

        $finish;
    end

    always begin
        #5 clk = ~clk;
    end

endmodule