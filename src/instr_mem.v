module instr_mem #(
    parameter PROG_NAME = "sample_prog0"
)
(
    input clk,
    input [31:0] addr,
    output reg [31:0] data_out
);

    reg [31:0] mem [1023:0]; // 4 KB instr mem

    initial begin
        $readmemh($sformatf("init/%s.mem", PROG_NAME), mem); // executes 'addi rs1, rs1, 1000' 5 times
    end

    always @ (posedge clk) begin
        data_out = mem[addr[9:0]];
    end

endmodule