`include "src/datapath.v"

module top(
    input clk,
    input reset
);

    // Instantiate the datapath module
    datapath dp (
        .clk(clk),
        .reset(reset)
    );

    // TODO: add IMem and DMem interfaces, I/O ports, etc.

endmodule