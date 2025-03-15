`include "src/memacc.v"

module memacc_tb();

    reg clk;
    reg [31:0] addr;
    reg write_enable;
    reg [31:0] data_in;

    wire [31:0] exec_data_out, mem_data_out, next_pc;
    wire rd_write_enable, res_src;
    wire [4:0] rd_write_addr;

    memacc memacc(
        .clk(clk),
        .next_pc_in(0),
        .rd_write_enable_in(0),
        .rd_write_addr_in(0),
        .res_src_in(0),
        .exec_data_in(addr),
        .mem_write_enable(write_enable),
        .mem_write_data(data_in),

        .exec_data_out(exec_data_out),
        .mem_data_out(mem_data_out),
        .next_pc_out(next_pc),
        .rd_write_enable_out(rd_write_enable),
        .rd_write_addr_out(rd_write_addr),
        .res_src_out(res_src)
    );

    initial begin
        $dumpfile("memacc_tb.vcd");
        $dumpvars();
        clk = 0;

        addr = 4;
        write_enable = 1;
        data_in = 32'hABCDABCD;
        #10;
        $display("addr = %h, w_en = %d, exec_data_out = %h, mem_data_out = %h", addr, write_enable, exec_data_out, mem_data_out);

        addr = 4;
        write_enable = 0;
        #10;
        $display("addr = %h, w_en = %d, exec_data_out = %h, mem_data_out = %h", addr, write_enable, exec_data_out, mem_data_out);

        addr = 8;
        write_enable = 0;
        #10;
        $display("addr = %h, w_en = %d, exec_data_out = %h, mem_data_out = %h", addr, write_enable, exec_data_out, mem_data_out);

        addr = 8;
        write_enable =  1;
        data_in = 32'hCDEFCDEF;
        #10;
        $display("addr = %h, w_en = %d, exec_data_out = %h, mem_data_out = %h", addr, write_enable, exec_data_out, mem_data_out);

        addr = 8;
        write_enable = 0;
        #10;
        $display("addr = %h, w_en = %d, exec_data_out = %h, mem_data_out = %h", addr, write_enable, exec_data_out, mem_data_out);

        $finish;
    end

    always begin
        #5 clk = ~clk;
    end

endmodule