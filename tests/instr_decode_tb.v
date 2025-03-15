`include "src/instr_decode.v"

module instr_decode_tb();

    reg clk;
    reg [31:0] instr;
    wire [31:0] pc, next_pc;
    wire rd_write_enable, res_src, branch, alu_input_conf;
    wire [5:0] alu_op;
    wire [31:0] imm, rs1_data, rs2_data;
    wire [4:0] rd_write_addr;

    instr_decode decode(
        .clk(clk),
        .instr(instr),
        .pc_in(0),
        .next_pc_in(0),
        .reg_write_data(0),     
        .reg_write_enable(0), 
        .reg_write_addr(0),  
        .pc_out(pc),
        .next_pc_out(next_pc),
        .rd_write_enable(rd_write_enable),
        .rd_write_addr(rd_write_addr),
        .res_src(res_src),
        .branch(branch),
        .alu_op(alu_op),
        .alu_input_conf(alu_input_conf),
        .imm(imm),
        .rs1_data(rs1_data),
        .rs2_data(rs2_data)
    );

    integer i;
    integer instrs[5] = {32'h3E808093, 32'h4B008093, 32'h57808093, 32'h64008093, 32'h70808093};
    initial begin
        $dumpfile("instr_decode_tb.vcd");
        $dumpvars();
        clk = 0;

        for (i = 0; i < 5; i++) begin
            instr = instrs[i];
            #10;
            $display("op: %h rd_write_enable: %d res_src: %d branch: %d alu_input_conf: %d imm: %d rs1: %d rs2: %d rd_write: %d", alu_op, rd_write_enable, res_src, branch, alu_input_conf, imm, $signed(rs1_data), rs2_data, rd_write_addr);
        end
        
        $finish;
    end

    always begin
        #5 clk = ~clk;
    end

endmodule