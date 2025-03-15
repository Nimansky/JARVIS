`include "src/data_mem.v"

module memacc(
    input clk,
    
    input [31:0] next_pc_in,
    input rd_write_enable_in, 
    input [4:0] rd_write_addr_in,
    input res_src_in, 

    input [31:0] exec_data_in,          // can either be used as address or forwarded to writeback as-is
    input mem_write_enable,
    input [31:0] mem_write_data,
    
    output [31:0] exec_data_out,
    output [31:0] mem_data_out,

    output [31:0] next_pc_out,
    output rd_write_enable_out,
    output [4:0] rd_write_addr_out,
    output res_src_out
);

    wire [31:0] mem_data;

    data_mem dm (
        .clk(clk),
        .addr(exec_data_in),
        .write_enable(mem_write_enable),
        .data_in(mem_write_data),
        .data_out(mem_data)
    );

    // pipeline registers
    reg [31:0] exec_data_out_reg, mem_data_out_reg, next_pc_out_reg;
    reg rd_write_enable_out_reg;
    reg [4:0] rd_write_addr_out_reg;
    reg res_src_out_reg;

    always @ (posedge clk) begin
        exec_data_out_reg <= exec_data_in;
        mem_data_out_reg <= mem_data;
        next_pc_out_reg <= next_pc_in;
        rd_write_enable_out_reg <= rd_write_enable_in;
        rd_write_addr_out_reg <= rd_write_addr_in;
        res_src_out_reg <= res_src_in;
    end

    assign exec_data_out = exec_data_out_reg;
    assign mem_data_out = mem_data_out_reg;
    assign next_pc_out = next_pc_out_reg;
    assign rd_write_enable_out = rd_write_enable_out_reg;
    assign rd_write_addr_out = rd_write_addr_out_reg;
    assign res_src_out = res_src_out_reg;

endmodule