`ifndef EXTENDER
`define EXTENDER

module extender(
    input [31:0] in,
    input [2:0] imm_sel,
    output [31:0] out
);

    // demux immediate types
    assign out = imm_sel == 3'b000 ? {{20{in[31]}}, in[31:20]} :        // I immediate
                 imm_sel == 3'b001 ? {in[31:12], 12'b0} :  // U immediate
                 imm_sel == 3'b010 ? {{12{in[31]}}, in[19:12], in[20], in[30:21], 1'b0} :  // J immediate
                 imm_sel == 3'b011 ? {{20{in[31]}}, in[7], in[30:25], in[11:8], 1'b0} :  // B immediate
                 imm_sel == 3'b100 ? {{21{in[31]}}, in[30:25], in[11:8], in[7]} :   // S immediate
                 32'b0;

endmodule

`endif