`include "src/constants.v"
`include "src/alu.v"
`include "src/mux.v"
`include "src/pc_adder.v"

module exec(
    input clk,
    input reset,
    input flush,
    input stall,

    input [5:0] alu_op,
    input [31:0] pc_in, 
    input [31:0] next_pc_in,
    input rd_write_enable,
    input [4:0] rd_write_addr, 
    input [1:0] res_src, 
    input branch, 
    input jump, 
    input mem_write_enable,
    input [2:0] mem_width_in,
    input alu_input_conf,
    input [31:0] imm, 
    input [31:0] rs1_data, 
    input [31:0] rs2_data,

    input [1:0] forward_rs1,
    input [1:0] forward_rs2,
    input [31:0] mem_forward,
    input [31:0] wb_forward,

    output [31:0] target_pc,
    output pc_src,

    output rd_write_enable_out,
    output [4:0] rd_write_addr_out,
    output [1:0] res_src_out,
    output mem_write_enable_out,
    output [2:0] mem_width_out,
    output [31:0] exec_out,
    output [31:0] mem_write_data_out,
    output [31:0] next_pc_out
);


    // intermediate wires
    wire [31:0] res_alu, in2, adder_in, tgt_plus_offset;
    wire a_less_b;

    wire [31:0] rs1_data_fwd, rs2_data_fwd;

    // these could potentially be 3-way-muxes if that'd be more practical for synthesis 
    assign rs1_data_fwd = forward_rs1 == 2'b10 ? wb_forward : 
                        forward_rs1 == 2'b01 ? mem_forward : 
                        forward_rs1 == 2'b00 ? rs1_data : 
                        32'h0;    // return 0 if invalid forward_rs1

    assign rs2_data_fwd = forward_rs2 == 2'b10 ? wb_forward : 
                        forward_rs2 == 2'b01 ? mem_forward : 
                        forward_rs2 == 2'b00 ? rs2_data : 
                        32'h0;    // return 0 if invalid forward_rs2

    mux in2_mux(
        .a(imm),
        .b(rs2_data_fwd),
        .sel(alu_input_conf),
        .out(in2)
    );

    alu alu(
        .a(rs1_data_fwd),
        .b(in2),
        .alu_op(alu_op),
        .result(res_alu),
        .a_less_b(a_less_b)
    );

    mux adder_in_mux(       // JALR adds rs1 + imm, AUIPC and all other jumps/branches add PC + imm => MUX to select between rs1 and PC
        .a(pc_in),
        .b(rs1_data_fwd),
        .sel(alu_op == `JALR || alu_op == `AUIPC),
        .out(adder_in)
    );

    pc_adder pc_adder(
        .a(adder_in),
        .b(imm),
        .out(tgt_plus_offset)
    );

    reg [31:0] out;
    reg [2:0] mem_width;
    always @ (*) begin
        case (alu_op)
            `ADDI,
            `ADD,
            `SLTIU,
            `SLTU,
            `SLT,
            `SLTI,
            `ANDI,
            `AND,
            `ORI,
            `OR,
            `XORI,
            `XOR,
            `SUB,
            `SLL,
            `SLLI,
            `SRL,
            `SRLI,
            `SRA,
            `SRAI,
            `LOAD,
            `STORE: out = res_alu;
            `AUIPC: out = tgt_plus_offset;
            `LUI: out = imm;
            default: out = 0;
        endcase
    end

    assign pc_src = jump || (branch && res_alu[0]) ? 1 : 0;
    assign target_pc = tgt_plus_offset; 

    // pipeline registers
    reg rd_write_enable_reg;
    reg [4:0] rd_write_addr_reg;
    reg [1:0] res_src_reg;
    reg mem_write_enable_reg;
    reg [31:0] exec_out_reg;
    reg [31:0] mem_write_data_reg;
    reg [2:0] mem_width_out_reg;
    reg [31:0] next_pc_reg;

    always @ (posedge clk or negedge reset) begin
        if (flush == 1'b1 || reset == 1'b0) begin
            rd_write_enable_reg <= 1'b0;
            rd_write_addr_reg <= 5'b00000;
            res_src_reg <= 2'b00;
            mem_write_enable_reg <= 1'b0;
    
            mem_width_out_reg <= 3'b000;
            exec_out_reg <= 32'h00000000;
            mem_write_data_reg <= 32'h00000000;
            next_pc_reg <= 32'h00000000;
        end else if (!stall) begin
            rd_write_enable_reg <= rd_write_enable;
            rd_write_addr_reg <= rd_write_addr;
            res_src_reg <= res_src;
            mem_write_enable_reg <= mem_write_enable;
    
            mem_width_out_reg <= mem_width_in;
            exec_out_reg <= out;
            mem_write_data_reg <= rs2_data_fwd;
            next_pc_reg <= next_pc_in;
        end
    end

    assign rd_write_enable_out = rd_write_enable_reg;
    assign rd_write_addr_out = rd_write_addr_reg;
    assign res_src_out = res_src_reg;
    assign mem_write_enable_out = mem_write_enable_reg;
    assign exec_out = exec_out_reg;
    assign mem_write_data_out = mem_write_data_reg;
    assign mem_width_out = mem_width_out_reg;
    assign next_pc_out = next_pc_reg;

endmodule