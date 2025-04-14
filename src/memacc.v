`include "src/data_mem.v"
`include "src/mem_extender.v"

module memacc(
    input clk,
    input reset,
    input flush,
    input stall,
    
    input [31:0] next_pc_in,
    input rd_write_enable_in, 
    input [4:0] rd_write_addr_in,
    input [1:0] res_src_in, 

    input [31:0] exec_data_in,          // can either be used as address or forwarded to writeback as-is
    input mem_write_enable,
    input [31:0] mem_write_data,
    input [2:0] mem_width,
    input valid_in,

    `ifdef RISCV_FORMAL
    // signals for RVFI
    input [31:0] rvfi_insn_in,
    input [31:0] rvfi_pc_rdata_in,
    input [31:0] rvfi_pc_wdata_in,
    input [4:0] rvfi_rs1_addr_in,
    input [4:0] rvfi_rs2_addr_in,
    input [31:0] rvfi_rs1_rdata_in,
    input [31:0] rvfi_rs2_rdata_in,
    `endif
    
    output [31:0] exec_data_out,
    output [31:0] mem_data_out,

    output [31:0] next_pc_out,
    output rd_write_enable_out,
    output [4:0] rd_write_addr_out,
    output [1:0] res_src_out,
    output valid_out

    `ifdef RISCV_FORMAL
    // signals for RVFI
    , output reg [31:0] rvfi_insn,
    output reg [31:0] rvfi_pc_rdata,
    output reg [31:0] rvfi_pc_wdata,
    output reg [4:0]  rvfi_rs1_addr,
    output reg [4:0]  rvfi_rs2_addr,
    output reg [31:0] rvfi_rs1_rdata,
    output reg [31:0] rvfi_rs2_rdata,
    output reg [31:0] rvfi_mem_addr,
    output reg [3:0]  rvfi_mem_rmask,
    output reg [3:0]  rvfi_mem_wmask,
    output reg [31:0] rvfi_mem_rdata,
    output reg [31:0] rvfi_mem_wdata
    `endif
);

    wire [31:0] mem_data;

    data_mem dm (
        .clk(clk),
        .addr(exec_data_in),
        .mem_width(mem_width),          // we implement our data_memory module to be able to load and store 8, 16 and 32 bits - if the memory can only handle 32 bits at once, we need to handle the other cases here instead
        .write_enable(mem_write_enable),
        .data_in(mem_write_data),
        .data_out(mem_data)
    );

    // depending on the width of the mem operation, we receive 8, 16 or 32 (unsigned or signed) bits from memory - extend them if necessary
    wire [31:0] mem_data_ext;
    mem_extender ext (
        .in(mem_data),
        .ext_sel(mem_width),
        .out(mem_data_ext)
    );

    // pipeline registers
    reg [31:0] exec_data_out_reg, mem_data_out_reg, next_pc_out_reg;
    reg rd_write_enable_out_reg;
    reg [4:0] rd_write_addr_out_reg;
    reg [1:0] res_src_out_reg;
    reg valid_out_reg;
    `ifdef RISCV_FORMAL
    reg [31:0] rvfi_insn_reg;
    reg [31:0] rvfi_pc_rdata_reg;
    reg [31:0] rvfi_pc_wdata_reg;
    reg [4:0]  rvfi_rs1_addr_reg;
    reg [4:0]  rvfi_rs2_addr_reg;
    reg [31:0] rvfi_rs1_rdata_reg;
    reg [31:0] rvfi_rs2_rdata_reg;
    reg [31:0] rvfi_mem_addr_reg;
    reg [3:0]  rvfi_mem_rmask_reg;
    reg [3:0]  rvfi_mem_wmask_reg;
    reg [31:0] rvfi_mem_rdata_reg;
    reg [31:0] rvfi_mem_wdata_reg;
    `endif

    always @ (posedge clk or negedge reset) begin
        if (flush == 1'b1 || reset == 1'b0) begin
            exec_data_out_reg <= 32'h00000000;
            mem_data_out_reg <= 32'h00000000;
            next_pc_out_reg <= 32'h00000000;
            rd_write_enable_out_reg <= 1'b0;
            rd_write_addr_out_reg <= 5'b00000;
            res_src_out_reg <= 2'b00;
            valid_out_reg <= 1'b0;
            `ifdef RISCV_FORMAL
            rvfi_insn_reg <= 32'h00000000;
            rvfi_pc_rdata_reg <= 32'h00000000;
            rvfi_pc_wdata_reg <= 32'h00000000;
            rvfi_rs1_addr_reg <= 5'b00000;
            rvfi_rs2_addr_reg <= 5'b00000;
            rvfi_rs1_rdata_reg <= 32'h00000000;
            rvfi_rs2_rdata_reg <= 32'h00000000;
            rvfi_mem_addr_reg <= 32'h00000000;
            rvfi_mem_rmask_reg <= 4'b0000;
            rvfi_mem_wmask_reg <= 4'b0000;
            rvfi_mem_rdata_reg <= 32'h00000000;
            rvfi_mem_wdata_reg <= 32'h00000000;
            `endif
        end else if (!stall) begin
            exec_data_out_reg <= exec_data_in;
            mem_data_out_reg <= mem_data_ext;
            next_pc_out_reg <= next_pc_in;
            rd_write_enable_out_reg <= rd_write_enable_in;
            rd_write_addr_out_reg <= rd_write_addr_in;
            res_src_out_reg <= res_src_in;
            valid_out_reg <= valid_in;
            `ifdef RISCV_FORMAL
            rvfi_insn_reg <= rvfi_insn_in;
            rvfi_pc_rdata_reg <= rvfi_pc_rdata_in;
            rvfi_pc_wdata_reg <= rvfi_pc_wdata_in;
            rvfi_rs1_addr_reg <= rvfi_rs1_addr_in;
            rvfi_rs2_addr_reg <= rvfi_rs2_addr_in;
            rvfi_rs1_rdata_reg <= rvfi_rs1_rdata_in;
            rvfi_rs2_rdata_reg <= rvfi_rs2_rdata_in;
            rvfi_mem_addr_reg <= mem_write_enable ? exec_data_in : 32'h00000000;
            rvfi_mem_rmask_reg <= res_src_in == 2'b01 ? (mem_width == 3'b000 ? 4'b0001 :
                                                mem_width == 3'b001 ? 4'b0011 :
                                                mem_width == 3'b010 ? 4'b1111 :
                                                mem_width == 3'b100 ? 4'b0001 :
                                                mem_width == 3'b101 ? 4'b0011 :
                                                4'b0000) 
                                                : 4'b0000;
            rvfi_mem_wmask_reg <= res_src_in == 2'b01 ? (mem_width == 3'b000 ? 4'b0001 :
                                                mem_width == 3'b001 ? 4'b0011 :
                                                mem_width == 3'b010 ? 4'b1111 :
                                                mem_width == 3'b100 ? 4'b0001 :
                                                mem_width == 3'b101 ? 4'b0011 : 
                                                4'b0000) 
                                                : 4'b0000;
            rvfi_mem_rdata_reg <= mem_data;
            rvfi_mem_wdata_reg <= mem_write_data;
            `endif
        end
    end

    assign exec_data_out = exec_data_out_reg;
    assign mem_data_out = mem_data_out_reg;
    assign next_pc_out = next_pc_out_reg;
    assign rd_write_enable_out = rd_write_enable_out_reg;
    assign rd_write_addr_out = rd_write_addr_out_reg;
    assign res_src_out = res_src_out_reg;
    assign valid_out = valid_out_reg;
    `ifdef RISCV_FORMAL
    assign rvfi_insn = rvfi_insn_reg;
    assign rvfi_pc_rdata = rvfi_pc_rdata_reg;
    assign rvfi_pc_wdata = rvfi_pc_wdata_reg;
    assign rvfi_rs1_addr = rvfi_rs1_addr_reg;
    assign rvfi_rs2_addr = rvfi_rs2_addr_reg;
    assign rvfi_rs1_rdata = rvfi_rs1_rdata_reg;
    assign rvfi_rs2_rdata = rvfi_rs2_rdata_reg;
    assign rvfi_mem_addr = rvfi_mem_addr_reg;
    assign rvfi_mem_rmask = rvfi_mem_rmask_reg;
    assign rvfi_mem_wmask = rvfi_mem_wmask_reg;
    assign rvfi_mem_rdata = rvfi_mem_rdata_reg;
    assign rvfi_mem_wdata = rvfi_mem_wdata_reg;
    `endif

endmodule