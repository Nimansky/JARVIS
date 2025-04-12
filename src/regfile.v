module regfile 
(
    input clk,
    input [4:0] read_addr1,
    input [4:0] read_addr2,
    input [31:0] data_in,
    input write_enable,
    input [4:0] write_addr,
    output reg [31:0] data_out1,
    output reg [31:0] data_out2
);

    reg [31:0] regs [31:0];

    // for simulation only
    initial begin

        // set all regs to 0
        $readmemh("init/regfile.mem", regs);
    end

    always @ (posedge clk) begin
        if (write_enable) begin
            regs[write_addr] = data_in;
        end 
        data_out1 = read_addr1 == 0 ? 32'h00000000 : regs[read_addr1];
        data_out2 = read_addr2 == 0 ? 32'h00000000 : regs[read_addr2];
    end
    
endmodule