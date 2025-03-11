`include "src/memacc.v"

module memacc_tb();

    reg clk;
    reg [31:0] addr;
    reg write_enable;
    reg [31:0] data_in;
    wire data_out_v;
    wire [31:0] data_out;

    memacc memacc (
        .clk(clk),
        .enable(1),
        .addr(addr),
        .write_enable(write_enable),
        .data_in(data_in),
        .data_out_v(data_out_v),
        .data_out(data_out)
    );

    initial begin
        $dumpfile("memacc_tb.vcd");
        $dumpvars();
        clk = 0;

        addr = 4;
        write_enable = 1;
        data_in = 32'hABCDABCD;
        #10;
        $display("addr = %h, data_out_v = %d, data_out = %h", addr, data_out_v, data_out);

        addr = 4;
        write_enable = 0;
        #10;
        $display("addr = %h, data_out_v = %d, data_out = %h", addr, data_out_v, data_out);

        addr = 8;
        write_enable = 0;
        #10;
        $display("addr = %h, data_out_v = %d, data_out = %h", addr, data_out_v, data_out);

        addr = 8;
        write_enable =  1;
        data_in = 32'hCDEFCDEF;
        #10;
        $display("addr = %h, data_out_v = %d, data_out = %h", addr, data_out_v, data_out);

        addr = 8;
        write_enable = 0;
        #10;
        $display("addr = %h, data_out_v = %d, data_out = %h", addr, data_out_v, data_out);

        $finish;
    end

    always begin
        #5 clk = ~clk;
    end

endmodule