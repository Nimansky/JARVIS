module writeback(
    input clk,
    input reset,
    input flush,
    input stall,

    input [31:0] exec_data_in,
    input [31:0] mem_data_in,
    input [31:0] next_pc,
    input [1:0] res_src,
    input valid_in,

    `ifdef RISCV_FORMAL
    // signals for RVFI
    input [31:0] rvfi_insn_in,
    input [31:0] rvfi_pc_rdata_in,
    input [31:0] rvfi_pc_wdata_in,
    input [4:0]  rvfi_rs1_addr_in,
    input [4:0]  rvfi_rs2_addr_in,
    input [31:0] rvfi_rs1_rdata_in,
    input [31:0] rvfi_rs2_rdata_in,
    input [4:0] rvfi_rd_addr_in,
    input [31:0] rvfi_mem_addr_in,
    input [3:0]  rvfi_mem_rmask_in,
    input [3:0]  rvfi_mem_wmask_in,
    input [31:0] rvfi_mem_rdata_in,
    input [31:0] rvfi_mem_wdata_in,
    `endif

    output [31:0] data_out,
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
    output reg [4:0]  rvfi_rd_addr,
    output reg [31:0] rvfi_rd_wdata,
    output reg [31:0] rvfi_mem_addr,
    output reg [3:0]  rvfi_mem_rmask,
    output reg [3:0]  rvfi_mem_wmask,
    output reg [31:0] rvfi_mem_rdata,
    output reg [31:0] rvfi_mem_wdata
    `endif

);

    // this could potentially be a 3-way-mux if that'd be more practical for synthesis 
    assign data_out = res_src == 2'b00 ? exec_data_in : 
                      res_src == 2'b01 ? mem_data_in : 
                      res_src == 2'b10 ? next_pc : 
                      32'h0;    // return 0 if invalid res_src
    

    reg valid_out_reg;
    `ifdef RISCV_FORMAL
    reg [31:0] rvfi_insn_reg;
    reg [31:0] rvfi_pc_rdata_reg;
    reg [31:0] rvfi_pc_wdata_reg;
    reg [4:0]  rvfi_rs1_addr_reg;
    reg [4:0]  rvfi_rs2_addr_reg;
    reg [31:0] rvfi_rs1_rdata_reg;
    reg [31:0] rvfi_rs2_rdata_reg;
    reg [4:0]  rvfi_rd_addr_reg;
    reg [31:0] rvfi_rd_wdata_reg;
    reg [31:0] rvfi_mem_addr_reg;
    reg [3:0]  rvfi_mem_rmask_reg;
    reg [3:0]  rvfi_mem_wmask_reg;
    reg [31:0] rvfi_mem_rdata_reg;
    reg [31:0] rvfi_mem_wdata_reg;
    `endif

    always @ (posedge clk or negedge reset) begin
        if (!reset || flush) begin
            valid_out_reg <= 1'b0;
            `ifdef RISCV_FORMAL
            rvfi_insn_reg <= 32'h00000000;
            rvfi_pc_rdata_reg <= 32'h00000000;
            rvfi_pc_wdata_reg <= 32'h00000000;
            rvfi_rs1_addr_reg <= 5'b00000;
            rvfi_rs2_addr_reg <= 5'b00000;
            rvfi_rs1_rdata_reg <= 32'h00000000;
            rvfi_rs2_rdata_reg <= 32'h00000000;
            rvfi_rd_addr_reg <= 5'b00000;
            rvfi_rd_wdata_reg <= 32'h00000000;
            rvfi_mem_addr_reg <= 32'h00000000;
            rvfi_mem_rmask_reg <= 4'b0000;
            rvfi_mem_wmask_reg <= 4'b0000;
            rvfi_mem_rdata_reg <= 32'h00000000;
            rvfi_mem_wdata_reg <= 32'h00000000;
            `endif
        end else if (!stall) begin
            valid_out_reg <= valid_in;
            `ifdef RISCV_FORMAL
            rvfi_insn_reg <= rvfi_insn_in;
            rvfi_pc_rdata_reg <= rvfi_pc_rdata_in;
            rvfi_pc_wdata_reg <= rvfi_pc_wdata_in;
            rvfi_rs1_addr_reg <= rvfi_rs1_addr_in;
            rvfi_rs2_addr_reg <= rvfi_rs2_addr_in;
            rvfi_rs1_rdata_reg <= rvfi_rs1_rdata_in;
            rvfi_rs2_rdata_reg <= rvfi_rs2_rdata_in;
            rvfi_rd_addr_reg <= rvfi_rd_addr_in;
            rvfi_rd_wdata_reg <= data_out;
            rvfi_mem_addr_reg <= rvfi_mem_addr_in;
            rvfi_mem_rmask_reg <= rvfi_mem_rmask_in;
            rvfi_mem_wmask_reg <= rvfi_mem_wmask_in;
            rvfi_mem_rdata_reg <= rvfi_mem_rdata_in;
            rvfi_mem_wdata_reg <= rvfi_mem_wdata_in;
            `endif
        end
    end

    assign valid_out = valid_out_reg;
    `ifdef RISCV_FORMAL
    assign rvfi_insn = rvfi_insn_reg;
    assign rvfi_pc_rdata = rvfi_pc_rdata_reg;
    assign rvfi_pc_wdata = rvfi_pc_wdata_reg;
    assign rvfi_rs1_addr = rvfi_rs1_addr_reg;
    assign rvfi_rs2_addr = rvfi_rs2_addr_reg;
    assign rvfi_rs1_rdata = rvfi_rs1_rdata_reg;
    assign rvfi_rs2_rdata = rvfi_rs2_rdata_reg;
    assign rvfi_rd_addr = rvfi_rd_addr_reg;
    assign rvfi_rd_wdata = rvfi_rd_wdata_reg;
    assign rvfi_mem_addr = rvfi_mem_addr_reg;
    assign rvfi_mem_rmask = rvfi_mem_rmask_reg;
    assign rvfi_mem_wmask = rvfi_mem_wmask_reg;
    assign rvfi_mem_rdata = rvfi_mem_rdata_reg;
    assign rvfi_mem_wdata = rvfi_mem_wdata_reg;
    `endif

endmodule