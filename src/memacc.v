`include "src/data_mem.v"

module memacc(
    input clk,
    input enable,
    input [31:0] addr,
    input write_enable,
    input [31:0] data_in,
    output reg data_out_v,
    output reg [31:0] data_out
);

    data_mem dm (
        .clk(clk),
        .enable(enable),
        .addr(addr),
        .write_enable(write_enable),
        .data_in(data_in),
        .data_out_v(data_out_v),
        .data_out(data_out)
    );

endmodule