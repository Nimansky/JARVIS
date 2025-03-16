`include "src/constants.v"

module decode_control_unit(
    input [31:0] instr,
    output reg reg_write_enable,
    output reg [1:0] result_src,              // 0 for alu, 1 for mem, 2 for pc+4
    output reg is_branch,
    output reg is_jump,
    output reg mem_write_enable,
    output reg [5:0] alu_op,
    output reg alu_input_config,        // 0 for rs1+rs2, 1 for rs1+imm
    output reg [2:0] imm_sel          // 0 for imm_i, 1 for imm_u, 2 for imm_j, 3 for imm_b, 4 for imm_s
);

    always @ (*) begin
        case (instr[6:0])
            7'b0110011: begin
                case (instr[14:12])
                    3'b000: begin
                        case (instr[31:25]) 
                            default: begin
                                // ??
                                reg_write_enable = 0;
                                result_src = 0;         // alu
                                is_branch = 0;
                                is_jump = 0;
                                mem_write_enable = 0;
                                alu_op = `NOP;          // ALU does nothing
                                alu_input_config = 0;        // doesnt matter since NOP
                                imm_sel = 0;            // imm_i
                            end
                            7'b0000000: begin
                                // ADD
                            end
                            7'b0100000: begin
                                // SUB
                            end
                        endcase
                    end
                    3'b001: begin
                        // SLL
                    end
                    3'b010: begin
                        // SLT
                    end
                    3'b011: begin
                        // SLTU
                    end
                    3'b100: begin
                        // XOR
                    end
                    3'b101: begin
                        case (instr[31:25])
                            default: begin
                                // ??
                                reg_write_enable = 0;
                                result_src = 0;         // alu
                                is_branch = 0;
                                is_jump = 0;
                                mem_write_enable = 0;
                                alu_op = `NOP;          // ALU does nothing
                                alu_input_config = 0;        // doesnt matter since NOP
                                imm_sel = 0;            // imm_i
                            end
                            7'b0000000: begin
                                // SRL
                            end
                            7'b0100000: begin
                                // SRA
                            end
                        endcase
                    end
                    3'b110: begin
                        // OR
                    end
                    3'b111: begin
                        // AND
                    end
                endcase
            end
            7'b0010011: begin
                case (instr[14:12])
                    3'b000: begin
                        // ADDI
                        alu_op = `ADDI;
                        reg_write_enable = 1;
                        result_src = 0;
                        is_branch = 0;
                        mem_write_enable = 0;
                        is_jump = 0;
                        alu_input_config = 0;
                        imm_sel = 0;
                    end
                    3'b001: begin
                        // SLLI
                    end
                    3'b010: begin
                        // SLTI
                    end
                    3'b011: begin
                        // SLTIU
                    end
                    3'b100: begin
                        // XORI
                    end
                    3'b101: begin
                        case (instr[31:25])
                            default: begin
                                // ??
                                reg_write_enable = 0;
                                result_src = 0;         // alu
                                is_branch = 0;
                                is_jump = 0;
                                mem_write_enable = 0;
                                alu_op = `NOP;          // ALU does nothing
                                alu_input_config = 0;        // doesnt matter since NOP
                                imm_sel = 0;            // imm_i
                            end
                            7'b0000000: begin
                                // SRLI
                            end
                            7'b0100000: begin
                                // SRAI
                            end
                        endcase
                    end
                    3'b110: begin
                        // ORI
                    end
                    3'b111: begin
                        // ANDI
                    end
                endcase
            end
            7'b0000011: begin
                case (instr[14:12])
                    3'b000: begin
                        // LB
                    end
                    3'b001: begin
                        // LH
                    end
                    3'b010: begin
                        // LW
                    end
                    3'b100: begin
                        // LBU
                    end
                    3'b101: begin
                        // LHU
                    end
                    default: begin
                        // ??
                        reg_write_enable = 0;
                        result_src = 0;         // alu
                        is_branch = 0;
                        is_jump = 0;
                        mem_write_enable = 0;
                        alu_op = `NOP;          // ALU does nothing
                        alu_input_config = 0;        // doesnt matter since NOP
                        imm_sel = 0;            // imm_i
                    end
                endcase
            end
            7'b0100011: begin
                case (instr[14:12])
                    3'b000: begin
                        // SB
                    end
                    3'b001: begin
                        // SH
                    end
                    3'b010: begin
                        // SW
                    end
                    default: begin
                        // ??
                        reg_write_enable = 0;
                        result_src = 0;         // alu
                        is_branch = 0;
                        is_jump = 0;
                        mem_write_enable = 0;
                        alu_op = `NOP;          // ALU does nothing
                        alu_input_config = 0;        // doesnt matter since NOP
                        imm_sel = 0;            // imm_i
                    end
                endcase
            end
            7'b1100011: begin
                case (instr[14:12])
                    3'b000: begin
                        // BEQ
                        reg_write_enable = 0;
                        result_src = 0;         // alu (doesn't matter)
                        is_branch = 1;
                        is_jump = 0;
                        mem_write_enable = 0;
                        alu_op = `BEQ;          // ALU calculates branch condition
                        alu_input_config = 1;        // rs1 and rs2
                        imm_sel = 3;            // imm_b
                    end
                    3'b001: begin
                        // BNE
                        reg_write_enable = 0;
                        result_src = 0;         // alu (doesn't matter)
                        is_branch = 1;
                        is_jump = 0;
                        mem_write_enable = 0;
                        alu_op = `BNE;          // ALU calculates branch condition
                        alu_input_config = 1;        // rs1 and rs2
                        imm_sel = 3;            // imm_b
                    end
                    3'b100: begin
                        // BLT
                        reg_write_enable = 0;
                        result_src = 0;         // alu (doesn't matter)
                        is_branch = 1;
                        is_jump = 0;
                        mem_write_enable = 0;
                        alu_op = `BLT;          // ALU calculates branch condition
                        alu_input_config = 1;        // rs1 and rs2
                        imm_sel = 3;            // imm_b
                    end
                    3'b101: begin
                        // BGE
                        reg_write_enable = 0;
                        result_src = 0;         // alu (doesn't matter)
                        is_branch = 1;
                        is_jump = 0;
                        mem_write_enable = 0;
                        alu_op = `BGE;          // ALU calculates branch condition
                        alu_input_config = 1;        // rs1 and rs2
                        imm_sel = 3;            // imm_b
                    end
                    3'b110: begin
                        // BLTU
                        reg_write_enable = 0;
                        result_src = 0;         // alu (doesn't matter)
                        is_branch = 1;
                        is_jump = 0;
                        mem_write_enable = 0;
                        alu_op = `BLTU;          // ALU calculates branch condition
                        alu_input_config = 1;        // rs1 and rs2
                        imm_sel = 3;            // imm_b
                    end
                    3'b111: begin
                        // BGEU
                        reg_write_enable = 0;
                        result_src = 0;         // alu (doesn't matter)
                        is_branch = 1;
                        is_jump = 0;
                        mem_write_enable = 0;
                        alu_op = `BGEU;          // ALU calculates branch condition
                        alu_input_config = 1;        // rs1 and rs2
                        imm_sel = 3;            // imm_b
                    end
                    default: begin
                        // ??
                        reg_write_enable = 0;
                        result_src = 0;         // alu
                        is_branch = 0;
                        is_jump = 0;
                        mem_write_enable = 0;
                        alu_op = `NOP;          // ALU does nothing
                        alu_input_config = 0;        // doesnt matter since NOP
                        imm_sel = 0;            // imm_i
                    end
                endcase
            end
            7'b1100111: begin
                // JALR
                reg_write_enable = 1;
                result_src = 2;         // next_pc
                is_branch = 0;
                is_jump = 1;
                mem_write_enable = 0;
                alu_op = `JALR;          // ALU does nothing
                alu_input_config = 0;        // doesnt matter
                imm_sel = 0;            // imm_i
            end
            7'b1101111: begin
                // JAL
                reg_write_enable = 1;
                result_src = 2;         // next_pc
                is_branch = 0;
                is_jump = 1;
                mem_write_enable = 0;
                alu_op = `JAL;          // ALU does nothing
                alu_input_config = 0;        // doesnt matter
                imm_sel = 2;            // imm_j
            end
            7'b0110111: begin
                // LUI
            end
            7'b0010111: begin
                // AUIPC
            end
            7'b1110011: begin
                case (instr[31:20])
                    12'h000: begin
                        // ECALL
                    end
                    12'h001: begin
                        // EBREAK
                    end
                    default: begin
                        // ??
                        reg_write_enable = 0;
                        result_src = 0;         // alu
                        is_branch = 0;
                        is_jump = 0;
                        mem_write_enable = 0;
                        alu_op = `NOP;          // ALU does nothing
                        alu_input_config = 0;        // doesnt matter since NOP
                        imm_sel = 0;            // imm_i
                    end
                endcase
            end
            default: begin
                // ?
                reg_write_enable = 0;
                result_src = 0;         // alu
                is_branch = 0;
                is_jump = 0;
                mem_write_enable = 0;
                alu_op = `NOP;          // ALU does nothing
                alu_input_config = 0;        // doesnt matter since NOP
                imm_sel = 0;            // imm_i
            end
        endcase
    end

endmodule