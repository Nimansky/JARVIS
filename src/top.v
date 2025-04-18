`include "src/datapath.v"
`include "src/data_mem.v"
`include "src/instr_mem.v"

module top(
    input clk,
    input reset

    `ifdef RISCV_FORMAL
    , output rvfi_valid,
    output [63:0] rvfi_order,
    output [31:0] rvfi_insn,
    output [31:0] rvfi_pc_rdata,
    output [31:0] rvfi_pc_wdata,
    output [4:0]  rvfi_rs1_addr,
    output [4:0]  rvfi_rs2_addr,
    output [31:0] rvfi_rs1_rdata,
    output [31:0] rvfi_rs2_rdata,
    output [4:0]  rvfi_rd_addr,
    output [31:0] rvfi_rd_wdata,
    output [31:0] rvfi_mem_addr,
    output [3:0]  rvfi_mem_rmask,
    output [3:0]  rvfi_mem_wmask,
    output [31:0] rvfi_mem_rdata,
    output [31:0] rvfi_mem_wdata,
    output rvfi_trap,
    output rvfi_halt,
    output rvfi_intr,
    output [1:0]  rvfi_mode,
    output [1:0]  rvfi_ixl
    `endif
);

    wire [31:0] dmem_req_addr;
    wire dmem_req_write_enable;
    wire [31:0] dmem_req_write_data;
    wire [2:0] dmem_req_data_width;
    wire dmem_req_ready;
    wire dmem_resp_valid;
    wire [31:0] dmem_resp_data_in;
    wire [31:0] imem_req_addr;
    wire imem_req_ready;
    wire imem_resp_valid;
    wire [31:0] imem_resp_data_in;


    // Instantiate the datapath module
    datapath dp (
        .clk(clk),
        .reset(reset),
        .dmem_req_addr(dmem_req_addr),
        .dmem_req_write_enable(dmem_req_write_enable),
        .dmem_req_write_data(dmem_req_write_data),
        .dmem_req_data_width(dmem_req_data_width),
        .dmem_req_ready(dmem_req_ready),
        .dmem_resp_data_in(dmem_resp_data_in),
        .dmem_resp_valid(dmem_resp_valid),
        .imem_req_addr(imem_req_addr),
        .imem_req_ready(imem_req_ready),
        .imem_resp_data_in(imem_resp_data_in),
        .imem_resp_valid(imem_resp_valid)

        `ifdef RISCV_FORMAL
        , .rvfi_valid(rvfi_valid),
        .rvfi_order(rvfi_order),
        .rvfi_insn(rvfi_insn),
        .rvfi_pc_rdata(rvfi_pc_rdata),
        .rvfi_pc_wdata(rvfi_pc_wdata),
        .rvfi_rs1_addr(rvfi_rs1_addr),
        .rvfi_rs2_addr(rvfi_rs2_addr),
        .rvfi_rs1_rdata(rvfi_rs1_rdata),
        .rvfi_rs2_rdata(rvfi_rs2_rdata),
        .rvfi_rd_addr(rvfi_rd_addr),
        .rvfi_rd_wdata(rvfi_rd_wdata),
        .rvfi_mem_addr(rvfi_mem_addr),
        .rvfi_mem_rmask(rvfi_mem_rmask),
        .rvfi_mem_wmask(rvfi_mem_wmask),
        .rvfi_mem_rdata(rvfi_mem_rdata),
        .rvfi_mem_wdata(rvfi_mem_wdata),
        .rvfi_trap(rvfi_trap),
        .rvfi_halt(rvfi_halt),
        .rvfi_intr(rvfi_intr),
        .rvfi_mode(rvfi_mode),
        .rvfi_ixl(rvfi_ixl)
        `endif
    );

    // TODO: exchange IMem and DMem dummies for real interfaces, add I/O ports, etc.

    instr_mem #(.PROG_NAME("sample_prog0")) im (
        .clk(clk),
        .addr(imem_req_addr),
        .data_out(imem_resp_data_in)
    );

    data_mem dm (
        .clk(clk),
        .addr(dmem_req_addr),
        .mem_width(dmem_req_data_width),          // we implement our data_memory module to be able to load and store 8, 16 and 32 bits - if the memory can only handle 32 bits at once, we need to handle the other cases here instead
        .write_enable(dmem_req_write_enable),
        .data_in(dmem_req_write_data),
        .data_out(dmem_resp_data_in)
    );

endmodule