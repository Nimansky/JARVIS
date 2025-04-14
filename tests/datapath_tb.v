`include "src/datapath.v"

module datapath_tb();

    reg clk;
    reg reset;
    `ifdef RISCV_FORMAL
    wire rvfi_valid;
    wire [63:0] rvfi_order;
    wire [31:0] rvfi_insn;
    wire [31:0] rvfi_pc_rdata;
    wire [31:0] rvfi_pc_wdata;
    wire [4:0] rvfi_rs1_addr;
    wire [4:0] rvfi_rs2_addr;
    wire [31:0] rvfi_rs1_rdata;
    wire [31:0] rvfi_rs2_rdata;
    wire [4:0] rvfi_rd_addr;
    wire [31:0] rvfi_rd_wdata;
    wire [31:0] rvfi_mem_addr;
    wire [3:0] rvfi_mem_rmask;
    wire [3:0] rvfi_mem_wmask;
    wire [31:0] rvfi_mem_rdata;
    wire [31:0] rvfi_mem_wdata;
    `endif

    datapath datapath(
        .clk(clk),
        .reset(reset)
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
        .rvfi_trap(),
        .rvfi_halt(),
        .rvfi_intr(),
        .rvfi_mode(),
        .rvfi_ixl()
        `endif
    );

    integer i;
    initial begin
        $dumpfile("datapath_tb.vcd");
        $dumpvars();
        reset = 0;
        reset = 1;
        clk = 0;

        for(i = 0; i < 20; i++) begin
            `ifndef RISCV_FORMAL

            $display("CYCLE: %d, PC: %d, reg[1]: %d, reg[2]: %d, reg[3]: %d, reg[4]: %d, reg[5]: %d, reg[6]: %d, reg[7]: %d", i, datapath.instr_fetch.pc_decode, $signed(datapath.decode.rf.regs[1]), $signed(datapath.decode.rf.regs[2]), $signed(datapath.decode.rf.regs[3]), $signed(datapath.decode.rf.regs[4]), $signed(datapath.decode.rf.regs[5]), $signed(datapath.decode.rf.regs[6]), $signed(datapath.decode.rf.regs[7])); 
            #10;

            `else

            $display("rvfi_valid: %d", rvfi_valid);
            $display("rvfi_order: %d", rvfi_order);
            $display("rvfi_insn: %h", rvfi_insn);
            $display("rvfi_pc_rdata: %h", rvfi_pc_rdata);
            $display("rvfi_pc_wdata: %h", rvfi_pc_wdata);
            $display("rvfi_rs1_addr: %d", rvfi_rs1_addr);
            $display("rvfi_rs2_addr: %d", rvfi_rs2_addr);
            $display("rvfi_rs1_rdata: %d", $signed(rvfi_rs1_rdata));
            $display("rvfi_rs2_rdata: %d", $signed(rvfi_rs2_rdata));
            $display("rvfi_rd_addr: %d", rvfi_rd_addr);
            $display("rvfi_rd_wdata: %d", $signed(rvfi_rd_wdata));
            $display("rvfi_mem_addr: %h", rvfi_mem_addr);
            $display("rvfi_mem_rmask: %b", rvfi_mem_rmask);
            $display("rvfi_mem_wmask: %b", rvfi_mem_wmask);
            $display("rvfi_mem_rdata: %h", rvfi_mem_rdata);
            $display("rvfi_mem_wdata: %h", rvfi_mem_wdata);
            $display("-----------------------------");
            #10;

            `endif
        end

        $finish;
    end

    always begin
        #5 clk = ~clk;
    end
endmodule