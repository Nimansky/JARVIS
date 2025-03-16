`ifndef MEM_EXTENDER
`define MEM_EXTENDER

module mem_extender(
    input [31:0] in,
    input [2:0] ext_sel,
    output [31:0] out
);

    // demux memory data lengths
    assign out = ext_sel == 3'b000 ? {{24{in[7]}}, in[7:0]} :        // byte
                 ext_sel == 3'b001 ? {{16{in[15]}}, in[15:0]} :  // half word
                 ext_sel == 3'b010 ? in :  // word
                 ext_sel == 3'b100 ? {24'b0, in[7:0]} :   // unsigned byte
                 ext_sel == 3'b101 ? {16'b0, in[15:0]} :   // unsigned half word
                 in;    // default

endmodule

`endif