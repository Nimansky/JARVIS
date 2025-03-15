module instr_mem #(
    parameter PROG_NAME = "sample_prog0"
)
(
    input clk,
    input [31:0] addr,
    output wire [31:0] data_out
);

    reg [7:0] mem [4095:0]; // 4 KB instr mem

    initial begin
        $readmemh($sformatf("init/%s.mem", PROG_NAME), mem);
    end

    assign data_out = {mem[addr[11:0]], mem[addr[11:0] + 1], mem[addr[11:0] + 2], mem[addr[11:0] + 3]};

endmodule