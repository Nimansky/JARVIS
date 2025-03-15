module writeback(
    input clk,

    input [31:0] exec_data_in,
    input [31:0] mem_data_in,
    input [31:0] next_pc,
    input [1:0] res_src,

    output [31:0] data_out
);

    // this could potentially be a 3-way-mux if that'd be more practical for synthesis 
    assign data_out = res_src == 2'b00 ? exec_data_in : 
                      res_src == 2'b01 ? mem_data_in : 
                      res_src == 2'b10 ? next_pc : 
                      32'h0;    // return 0 if invalid res_src

endmodule