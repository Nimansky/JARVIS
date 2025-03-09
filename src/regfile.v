module regfile 
(
    input clk,
    input [4:0] read_addr,
    input [31:0] data_in,
    input write_enable,
    input [4:0] write_addr,
    output [31:0] data_out
);

    reg [31:0] regs [31:0];

    // for simulation only
    initial begin

        // set all regs to 0
        $readmemh("init/regfile.mem", regs);
    end

    always @ (posedge clk) begin
        if (write_enable) begin
            regs[write_addr] <= data_in;
        end
    end
    
    assign data_out = regs[read_addr];
    
endmodule