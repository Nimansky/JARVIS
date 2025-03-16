module data_mem (
    input clk,
    input [31:0] addr,
    input [2:0] mem_width,
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
            case (mem_width)
                3'b000: mem[addr[20:0]] <= data_in[7:0];
                3'b001: begin
                    mem[addr[20:0] + 1] <= data_in[15:8];
                    mem[addr[20:0]] <= data_in[7:0];
                end
                3'b010: begin
                    mem[addr[20:0] + 3] <= data_in[31:24];
                    mem[addr[20:0] + 2] <= data_in[23:16];
                    mem[addr[20:0] + 1] <= data_in[15:8];
                    mem[addr[20:0]] <= data_in[7:0];
                end
                default: begin
                    // NOP
                end
            endcase
        end
    end

    reg [31:0] tmp_out;
    always @ (*) begin
        case (mem_width) 
            3'b000: tmp_out = {24'b0, mem[addr[20:0]]};
            3'b001: tmp_out = {16'b0, mem[addr[20:0] + 1], mem[addr[20:0]]};
            3'b010: tmp_out = {mem[addr[20:0] + 3], mem[addr[20:0] + 2], mem[addr[20:0] + 1], mem[addr[20:0]]};
            default: tmp_out = 0;
        endcase
    end

    assign data_out = tmp_out;

endmodule