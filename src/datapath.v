`include "src/instr_fetch.v"
`include "src/instr_decode.v"
`include "src/exec.v"
`include "src/memacc.v"
`include "src/writeback.v"
`include "src/hazard_unit.v"

module datapath (
    input clk,
    input reset
    // TODO: add interface signals for stuff like IMem/DMem interface, I/O ports, etc.

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

    // we should stall for IMem and DMem accesses and other multi cycle ops
    // we don't have any multicycle ops yet
    // so for now: stall just 1 cycle for single cycle mem accesses (i.e. for our mem models)
    wire if_stall = exec_to_memacc_res_src == 1; // we need to stall if ma stage contains a load/store
    wire id_stall = exec_to_memacc_res_src == 1; 
    wire exec_stall = exec_to_memacc_res_src == 1;
    wire ma_stall = 0;  // we don't have any multicycle ops yet
    wire wb_stall = 0;  // we don't have any multicycle ops yet

    wire if_flush = exec_to_fetch_pc_src;
    wire id_flush = exec_to_fetch_pc_src;
    wire exec_flush = 0;    // so far there's no case where we flush exec, ma or wb
    wire ma_flush = 0;
    wire wb_flush = 0;

    // concept for all stages:
    // wire for all outputs
    // store results in regs at each posedge clk

    wire [31:0] fetch_to_decode_pc, fetch_to_decode_next_pc, fetch_to_decode_instr;
    wire fetch_to_decode_valid;

    wire [31:0] exec_to_fetch_target_pc;        // fed back from exec stage
    wire exec_to_fetch_pc_src;                  // fed back from exec stage

    instr_fetch instr_fetch(
        .clk(clk),
        .reset(reset),
        .flush(if_flush),
        .stall(if_stall),
        .pc_target_exec(exec_to_fetch_target_pc),  
        .pc_src_exec(exec_to_fetch_pc_src),            // 0 means PC should be incremented by 4 - needs output from exec
        .instr_decode(fetch_to_decode_instr),
        .pc_decode(fetch_to_decode_pc),
        .next_pc_decode(fetch_to_decode_next_pc),
        .valid(fetch_to_decode_valid)
    );

    wire [31:0] decode_to_exec_pc, decode_to_exec_next_pc;
    wire [1:0] decode_to_exec_res_src;
    wire decode_to_exec_rd_write_enable, decode_to_exec_branch, decode_to_exec_jump, decode_to_exec_mem_write_enable, decode_to_exec_alu_input_conf;
    wire [5:0] decode_to_exec_alu_op;
    wire [31:0] decode_to_exec_imm, decode_to_exec_rs1_data, decode_to_exec_rs2_data;
    wire [4:0] decode_to_hazard_rs1_addr, decode_to_hazard_rs2_addr, decode_to_exec_rd_write_addr;
    wire [2:0] decode_to_exec_mem_width;
    wire decode_to_exec_valid;
    `ifdef RISCV_FORMAL
    // signals for RVFI
    wire [31:0] decode_to_exec_rvfi_insn;
    `endif

    wire [31:0] writeback_to_decode_data_out; // fed back from writeback stage
    wire writeback_to_decode_write_enable; // fed back from writeback stage
    wire [4:0] writeback_to_decode_write_addr; // fed back from writeback stage

    instr_decode decode(
        .clk(clk),
        .reset(reset),
        .flush(id_flush),
        .stall(id_stall),
        .instr(fetch_to_decode_instr),
        .pc_in(fetch_to_decode_pc),
        .next_pc_in(fetch_to_decode_next_pc),
        .reg_write_data(writeback_to_decode_data_out),     
        .reg_write_enable(writeback_to_decode_write_enable),
        .reg_write_addr(writeback_to_decode_write_addr),
        .valid_in(fetch_to_decode_valid),
        .pc_out(decode_to_exec_pc),
        .next_pc_out(decode_to_exec_next_pc),
        .rd_write_enable(decode_to_exec_rd_write_enable),
        .rd_write_addr(decode_to_exec_rd_write_addr),
        .res_src(decode_to_exec_res_src),
        .branch(decode_to_exec_branch),
        .jump(decode_to_exec_jump),
        .mem_width_out(decode_to_exec_mem_width),
        .mem_write_enable(decode_to_exec_mem_write_enable),
        .alu_op(decode_to_exec_alu_op),
        .alu_input_conf(decode_to_exec_alu_input_conf),
        .imm(decode_to_exec_imm),
        .rs1_addr(decode_to_hazard_rs1_addr),
        .rs1_data(decode_to_exec_rs1_data),
        .rs2_addr(decode_to_hazard_rs2_addr),
        .rs2_data(decode_to_exec_rs2_data),
        .valid_out(decode_to_exec_valid)
        `ifdef RISCV_FORMAL
        // signals for RVFI
        , .rvfi_insn(decode_to_exec_rvfi_insn)
        `endif
    );
    
    wire [1:0] exec_to_memacc_res_src;
    wire exec_to_memacc_rd_write_enable, exec_to_memacc_mem_write_enable;
    wire [4:0] exec_to_memacc_rd_write_addr;
    wire [31:0] exec_to_memacc_data_out;
    wire [31:0] exec_to_memacc_mem_write_data_out;
    wire [31:0] exec_to_memacc_next_pc;
    wire [2:0] exec_to_memacc_mem_width;
    wire [1:0] hazard_to_exec_forward_rs1, hazard_to_exec_forward_rs2;
    wire exec_to_memacc_valid;
    `ifdef RISCV_FORMAL
    // signals for RVFI
    wire [31:0] exec_to_memacc_rvfi_insn;
    wire [31:0] exec_to_memacc_rvfi_pc_rdata;
    wire [31:0] exec_to_memacc_rvfi_pc_wdata;
    wire [4:0]  exec_to_memacc_rvfi_rs1_addr;
    wire [4:0]  exec_to_memacc_rvfi_rs2_addr;
    wire [31:0] exec_to_memacc_rvfi_rs1_rdata;
    wire [31:0] exec_to_memacc_rvfi_rs2_rdata;
    wire [4:0]  exec_to_memacc_rvfi_rd_addr;
    `endif

    exec exec(
        .clk(clk),
        .reset(reset),
        .flush(exec_flush),
        .stall(exec_stall),
        .alu_op(decode_to_exec_alu_op),
        .pc_in(decode_to_exec_pc),
        .next_pc_in(decode_to_exec_next_pc),
        .rd_write_enable(decode_to_exec_rd_write_enable),
        .rd_write_addr(decode_to_exec_rd_write_addr),
        .res_src(decode_to_exec_res_src),
        .branch(decode_to_exec_branch),
        .jump(decode_to_exec_jump),
        .mem_write_enable(decode_to_exec_mem_write_enable),
        .mem_width_in(decode_to_exec_mem_width),
        .alu_input_conf(decode_to_exec_alu_input_conf),
        .imm(decode_to_exec_imm),
        .rs1_data(decode_to_exec_rs1_data),
        .rs2_data(decode_to_exec_rs2_data),

        .forward_rs1(hazard_to_exec_forward_rs1),
        .forward_rs2(hazard_to_exec_forward_rs2),
        .mem_forward(exec_to_memacc_data_out),
        .wb_forward(writeback_to_decode_data_out),  //memacc_to_wb_exec_data_out
        .valid_in(decode_to_exec_valid),

        `ifdef RISCV_FORMAL
        // signals for RVFI
        .rvfi_insn_in(decode_to_exec_rvfi_insn),
        .rvfi_rs1_addr_in(decode_to_hazard_rs1_addr),
        .rvfi_rs2_addr_in(decode_to_hazard_rs2_addr),
        `endif

        .target_pc(exec_to_fetch_target_pc),
        .pc_src(exec_to_fetch_pc_src),

        .rd_write_enable_out(exec_to_memacc_rd_write_enable),
        .rd_write_addr_out(exec_to_memacc_rd_write_addr),
        .res_src_out(exec_to_memacc_res_src),
        .mem_write_enable_out(exec_to_memacc_mem_write_enable),
        .mem_width_out(exec_to_memacc_mem_width),
        .exec_out(exec_to_memacc_data_out),
        .mem_write_data_out(exec_to_memacc_mem_write_data_out),
        .next_pc_out(exec_to_memacc_next_pc),
        .valid_out(exec_to_memacc_valid)
        `ifdef RISCV_FORMAL
        // signals for RVFI
        , .rvfi_insn(exec_to_memacc_rvfi_insn),
        .rvfi_pc_rdata(exec_to_memacc_rvfi_pc_rdata),
        .rvfi_pc_wdata(exec_to_memacc_rvfi_pc_wdata),
        .rvfi_rs1_addr(exec_to_memacc_rvfi_rs1_addr),
        .rvfi_rs2_addr(exec_to_memacc_rvfi_rs2_addr),
        .rvfi_rs1_rdata(exec_to_memacc_rvfi_rs1_rdata),
        .rvfi_rs2_rdata(exec_to_memacc_rvfi_rs2_rdata),
        .rvfi_rd_addr(exec_to_memacc_rvfi_rd_addr)
        `endif
    );

    wire [31:0] memacc_to_wb_exec_data_out, memacc_to_wb_mem_data_out, memacc_to_wb_next_pc;
    wire [1:0] memacc_to_wb_res_src;
    wire memacc_to_wb_valid;
    `ifdef RISCV_FORMAL
    // signals for RVFI
    wire [31:0] memacc_to_wb_rvfi_insn;
    wire [31:0] memacc_to_wb_rvfi_pc_rdata;
    wire [31:0] memacc_to_wb_rvfi_pc_wdata;
    wire [4:0]  memacc_to_wb_rvfi_rs1_addr;
    wire [4:0]  memacc_to_wb_rvfi_rs2_addr;
    wire [31:0] memacc_to_wb_rvfi_rs1_rdata;
    wire [31:0] memacc_to_wb_rvfi_rs2_rdata;
    wire [31:0] memacc_to_wb_rvfi_mem_addr;
    wire [3:0]  memacc_to_wb_rvfi_mem_rmask;
    wire [3:0]  memacc_to_wb_rvfi_mem_wmask;
    wire [31:0] memacc_to_wb_rvfi_mem_rdata;
    wire [31:0] memacc_to_wb_rvfi_mem_wdata;
    `endif

    memacc memacc(
        .clk(clk),
        .reset(reset),
        .flush(ma_flush),
        .stall(ma_stall),
        .next_pc_in(exec_to_memacc_next_pc),
        .rd_write_enable_in(exec_to_memacc_rd_write_enable),
        .rd_write_addr_in(exec_to_memacc_rd_write_addr),
        .res_src_in(exec_to_memacc_res_src),
        .exec_data_in(exec_to_memacc_data_out),
        .mem_write_enable(exec_to_memacc_mem_write_enable),
        .mem_write_data(exec_to_memacc_mem_write_data_out),
        .mem_width(exec_to_memacc_mem_width),
        .valid_in(exec_to_memacc_valid),
        `ifdef RISCV_FORMAL
        // signals for RVFI
        .rvfi_insn_in(exec_to_memacc_rvfi_insn),
        .rvfi_pc_rdata_in(exec_to_memacc_rvfi_pc_rdata),
        .rvfi_pc_wdata_in(exec_to_memacc_rvfi_pc_wdata),
        .rvfi_rs1_addr_in(exec_to_memacc_rvfi_rs1_addr),
        .rvfi_rs2_addr_in(exec_to_memacc_rvfi_rs2_addr),
        .rvfi_rs1_rdata_in(exec_to_memacc_rvfi_rs1_rdata),
        .rvfi_rs2_rdata_in(exec_to_memacc_rvfi_rs2_rdata),
        `endif
        .exec_data_out(memacc_to_wb_exec_data_out),
        .mem_data_out(memacc_to_wb_mem_data_out),
        .next_pc_out(memacc_to_wb_next_pc),
        .rd_write_enable_out(writeback_to_decode_write_enable),
        .rd_write_addr_out(writeback_to_decode_write_addr),
        .res_src_out(memacc_to_wb_res_src),
        .valid_out(memacc_to_wb_valid)
        `ifdef RISCV_FORMAL
        // signals for RVFI
        , .rvfi_insn(memacc_to_wb_rvfi_insn),
        .rvfi_pc_rdata(memacc_to_wb_rvfi_pc_rdata),
        .rvfi_pc_wdata(memacc_to_wb_rvfi_pc_wdata),
        .rvfi_rs1_addr(memacc_to_wb_rvfi_rs1_addr),
        .rvfi_rs2_addr(memacc_to_wb_rvfi_rs2_addr),
        .rvfi_rs1_rdata(memacc_to_wb_rvfi_rs1_rdata),
        .rvfi_rs2_rdata(memacc_to_wb_rvfi_rs2_rdata),
        .rvfi_mem_addr(memacc_to_wb_rvfi_mem_addr),
        .rvfi_mem_rmask(memacc_to_wb_rvfi_mem_rmask),
        .rvfi_mem_wmask(memacc_to_wb_rvfi_mem_wmask),
        .rvfi_mem_rdata(memacc_to_wb_rvfi_mem_rdata),
        .rvfi_mem_wdata(memacc_to_wb_rvfi_mem_wdata)
        `endif
    );

    wire wb_valid;
    `ifdef RISCV_FORMAL
    // signals for RVFI
    wire [31:0] ret_rvfi_insn;
    wire [31:0] ret_rvfi_pc_rdata;
    wire [31:0] ret_rvfi_pc_wdata;
    wire [4:0]  ret_rvfi_rs1_addr;
    wire [4:0]  ret_rvfi_rs2_addr;
    wire [31:0] ret_rvfi_rs1_rdata;
    wire [31:0] ret_rvfi_rs2_rdata;
    wire [4:0]  ret_rvfi_rd_addr;
    wire [31:0] ret_rvfi_rd_wdata;
    wire [31:0] ret_rvfi_mem_addr;
    wire [3:0]  ret_rvfi_mem_rmask;
    wire [3:0]  ret_rvfi_mem_wmask;
    wire [31:0] ret_rvfi_mem_rdata;
    wire [31:0] ret_rvfi_mem_wdata;
    `endif

    writeback writeback(
        .clk(clk),
        .reset(reset),
        .flush(wb_flush),
        .stall(wb_stall),
        .exec_data_in(memacc_to_wb_exec_data_out),
        .mem_data_in(memacc_to_wb_mem_data_out),
        .next_pc(memacc_to_wb_next_pc),
        .res_src(memacc_to_wb_res_src),
        .valid_in(memacc_to_wb_valid),
        `ifdef RISCV_FORMAL
        // signals for RVFI
        .rvfi_insn_in(memacc_to_wb_rvfi_insn),
        .rvfi_pc_rdata_in(memacc_to_wb_rvfi_pc_rdata),
        .rvfi_pc_wdata_in(memacc_to_wb_rvfi_pc_wdata),
        .rvfi_rs1_addr_in(memacc_to_wb_rvfi_rs1_addr),
        .rvfi_rs2_addr_in(memacc_to_wb_rvfi_rs2_addr),
        .rvfi_rs1_rdata_in(memacc_to_wb_rvfi_rs1_rdata),
        .rvfi_rs2_rdata_in(memacc_to_wb_rvfi_rs2_rdata),
        .rvfi_rd_addr_in(writeback_to_decode_write_addr),
        .rvfi_mem_addr_in(memacc_to_wb_rvfi_mem_addr),
        .rvfi_mem_rmask_in(memacc_to_wb_rvfi_mem_rmask),
        .rvfi_mem_wmask_in(memacc_to_wb_rvfi_mem_wmask),
        .rvfi_mem_rdata_in(memacc_to_wb_rvfi_mem_rdata),
        .rvfi_mem_wdata_in(memacc_to_wb_rvfi_mem_wdata),
        `endif
        .data_out(writeback_to_decode_data_out),
        .valid_out(wb_valid)
        `ifdef RISCV_FORMAL
        // signals for RVFI
        , .rvfi_insn(ret_rvfi_insn),
        .rvfi_pc_rdata(ret_rvfi_pc_rdata),
        .rvfi_pc_wdata(ret_rvfi_pc_wdata),
        .rvfi_rs1_addr(ret_rvfi_rs1_addr),
        .rvfi_rs2_addr(ret_rvfi_rs2_addr),
        .rvfi_rs1_rdata(ret_rvfi_rs1_rdata),
        .rvfi_rs2_rdata(ret_rvfi_rs2_rdata),
        .rvfi_rd_addr(ret_rvfi_rd_addr),
        .rvfi_rd_wdata(ret_rvfi_rd_wdata),
        .rvfi_mem_addr(ret_rvfi_mem_addr),
        .rvfi_mem_rmask(ret_rvfi_mem_rmask),
        .rvfi_mem_wmask(ret_rvfi_mem_wmask),
        .rvfi_mem_rdata(ret_rvfi_mem_rdata),
        .rvfi_mem_wdata(ret_rvfi_mem_wdata)
        `endif
    );

    hazard_unit hazard_unit(
        .clk(clk),
        .exec_rs1_addr(decode_to_hazard_rs1_addr),
        .exec_rs2_addr(decode_to_hazard_rs2_addr),

        .mem_rd_addr(exec_to_memacc_rd_write_addr),
        .mem_rd_write_enable(exec_to_memacc_rd_write_enable),

        .wb_rd_addr(writeback_to_decode_write_addr),
        .wb_rd_write_enable(writeback_to_decode_write_enable),

        .forward_rs1(hazard_to_exec_forward_rs1),
        .forward_rs2(hazard_to_exec_forward_rs2)
    );

    `ifdef RISCV_FORMAL
    reg [63:0] rvfi_cnt;
    always @(posedge clk or negedge reset) begin
        if (!reset) begin
            rvfi_cnt <= 0;
        end else if (wb_valid) begin
            rvfi_cnt <= rvfi_cnt + 1;
        end
    end
    assign rvfi_valid = wb_valid;
    assign rvfi_order = rvfi_cnt;
    assign rvfi_insn = ret_rvfi_insn;
    assign rvfi_pc_rdata = ret_rvfi_pc_rdata;
    assign rvfi_pc_wdata = ret_rvfi_pc_wdata;
    assign rvfi_rs1_addr = ret_rvfi_rs1_addr;
    assign rvfi_rs2_addr = ret_rvfi_rs2_addr;
    assign rvfi_rs1_rdata = ret_rvfi_rs1_rdata;
    assign rvfi_rs2_rdata = ret_rvfi_rs2_rdata;
    assign rvfi_rd_addr = ret_rvfi_rd_addr;
    assign rvfi_rd_wdata = ret_rvfi_rd_wdata;
    assign rvfi_mem_addr = ret_rvfi_mem_addr;
    assign rvfi_mem_rmask = ret_rvfi_mem_rmask;
    assign rvfi_mem_wmask = ret_rvfi_mem_wmask;
    assign rvfi_mem_rdata = ret_rvfi_mem_rdata;
    assign rvfi_mem_wdata = ret_rvfi_mem_wdata;
    assign rvfi_trap = 0;       // trapping not supported yet
    assign rvfi_halt = 0;       // halting not supported yet
    assign rvfi_intr = 0;       // interrupts not supported yet
    assign rvfi_mode = 2'b11; // Machine mode
    assign rvfi_ixl  = 2'b01; // RV32 (fixed width)
    `endif


endmodule