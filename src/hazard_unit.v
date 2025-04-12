module hazard_unit(
    input clk,
    input [4:0] exec_rs1_addr,
    input [4:0] exec_rs2_addr,

    input [4:0] mem_rd_addr,
    input mem_rd_write_enable,

    input [4:0] wb_rd_addr,
    input wb_rd_write_enable,

    output [1:0] forward_rs1,       // 0 for no forward, 1 for mem, 2 for wb
    output [1:0] forward_rs2        // 0 for no forward, 1 for mem, 2 for wb
);

    wire mem_hazard_rs1, mem_hazard_rs2, wb_hazard_rs1, wb_hazard_rs2;

    assign mem_hazard_rs1 = (exec_rs1_addr == mem_rd_addr && mem_rd_write_enable);
    assign mem_hazard_rs2 = (exec_rs2_addr == mem_rd_addr && mem_rd_write_enable);
    assign wb_hazard_rs1 = (exec_rs1_addr == wb_rd_addr && wb_rd_write_enable);
    assign wb_hazard_rs2 = (exec_rs2_addr == wb_rd_addr && wb_rd_write_enable);

    // explanation:
    // if a reg is written in both the mem and wb stage, then we want to use the result from the mem stage,
    // because it is more recent. therefore in the ternary operator, we check for mem first.
    assign forward_rs1 = (mem_hazard_rs1) ? 1 : (wb_hazard_rs1) ? 2 : 0;
    assign forward_rs2 = (mem_hazard_rs2) ? 1 : (wb_hazard_rs2) ? 2 : 0;

endmodule;