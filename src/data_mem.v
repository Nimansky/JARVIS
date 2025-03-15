module data_mem (
    input clk,
    input [31:0] addr,
    input write_enable,
    input [31:0] data_in,
    output reg [31:0] data_out
);

    reg [7:0] mem [2097151:0]; // 2 MB data mem

    initial begin
        integer i;
        for(i = 0; i < 2097152; i = i + 1) begin
            mem[i] = i[7:0];
        end
    end

    always @ (posedge clk) begin
        if(write_enable) begin
            mem[addr[20:0]] <= data_in[31:24];
            mem[addr[20:0] + 1] <= data_in[23:16];
            mem[addr[20:0] + 2] <= data_in[15:8];
            mem[addr[20:0] + 3] <= data_in[7:0];
        end
    end

    assign data_out = {mem[addr[20:0]], mem[addr[20:0] + 1], mem[addr[20:0] + 2], mem[addr[20:0] + 3]};

endmodule