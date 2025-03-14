`include "src/regfile.v"

module regfile_tb();

    reg clk;
    reg [4:0] read_addr1;
    reg [4:0] read_addr2;
    reg [31:0] data_in;
    reg write_enable;
    reg [4:0] write_addr;
    wire [31:0] data_out1;
    wire [31:0] data_out2;

    regfile regfile(
        .clk(clk),
        .read_addr1(read_addr1),
        .read_addr2(read_addr2),
        .data_in(data_in),
        .write_enable(write_enable),
        .write_addr(write_addr),
        .data_out1(data_out1),
        .data_out2(data_out2)
    );

    initial begin
        $dumpfile("regfile_tb.vcd");
        $dumpvars();
        clk = 0;

        // write but dont read
        read_addr1 = 0;
        write_addr = 5'd1;
        data_in = 10;
        write_enable = 1;
        #10;
        $display("write_addr = %d, read_addr = %d, data_in = %d, write_enable = %d, data_out = %d", write_addr, read_addr1, data_in, write_enable, data_out1);

        // write and read
        read_addr1 = 5'd2;
        write_addr = 5'd2;
        data_in = 20;
        write_enable = 1;
        #10;
        $display("write_addr = %d, read_addr = %d, data_in = %d, write_enable = %d, data_out = %d", write_addr, read_addr1, data_in, write_enable, data_out1);
        
        // read and no write
        read_addr1 = 5'd1;
        write_addr = 0;
        data_in = 0;
        write_enable = 0;
        #10;
        $display("write_addr = %d, read_addr = %d, data_in = %d, write_enable = %d, data_out = %d", write_addr, read_addr1, data_in, write_enable, data_out1);

        $finish;
    end
    
    always begin
        #5 clk = ~clk;
    end

endmodule