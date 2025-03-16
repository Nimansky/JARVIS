`include "src/constants.v"

module decode_control_unit(
    input [31:0] instr,
    output reg reg_write_enable,
    output reg [1:0] result_src,              // 0 for alu, 1 for mem, 2 for pc+4
    output reg is_branch,
    output reg is_jump,
    output reg mem_write_enable,
    output reg [2:0] mem_width,
    output reg [5:0] alu_op,
    output reg alu_input_config,        // 1 for rs1+rs2, 0 for rs1+imm
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
                                mem_width = 0;          // doesn't matter since no memory operation
                                mem_write_enable = 0;
                                alu_op = `NOP;          // ALU does nothing
                                alu_input_config = 1;        // doesnt matter since NOP
                                imm_sel = 0;            // imm_i
                            end
                            7'b0000000: begin
                                // ADD
                                reg_write_enable = 1;
                                result_src = 0;         // alu
                                is_branch = 0;
                                is_jump = 0;
                                mem_width = 0;          // doesn't matter since no memory operation
                                mem_write_enable = 0;
                                alu_op = `ADD;
                                alu_input_config = 1;        // rs1 + rs2
                                imm_sel = 0;            // doesnt matter since no immediate
                            end
                            7'b0100000: begin
                                // SUB
                                reg_write_enable = 1;
                                result_src = 0;         // alu
                                is_branch = 0;
                                is_jump = 0;
                                mem_width = 0;          // doesn't matter since no memory operation
                                mem_write_enable = 0;
                                alu_op = `SUB;
                                alu_input_config = 1;        // rs1 + rs2
                                imm_sel = 0;            // doesnt matter since no immediate
                            end
                        endcase
                    end
                    3'b001: begin
                        // SLL
                        reg_write_enable = 1;
                        result_src = 0;         // alu
                        is_branch = 0;
                        is_jump = 0;
                        mem_width = 0;          // doesn't matter since no memory operation
                        mem_write_enable = 0;
                        alu_op = `SLL;
                        alu_input_config = 1;        // rs1 + rs2
                        imm_sel = 0;            // doesnt matter since no immediate
                    end
                    3'b010: begin
                        // SLT
                        reg_write_enable = 1;
                        result_src = 0;         // alu
                        is_branch = 0;
                        is_jump = 0;
                        mem_width = 0;          // doesn't matter since no memory operation
                        mem_write_enable = 0;
                        alu_op = `SLT;
                        alu_input_config = 1;        // rs1 + rs2
                        imm_sel = 0;            // doesnt matter since no immediate
                    end
                    3'b011: begin
                        // SLTU
                        reg_write_enable = 1;
                        result_src = 0;         // alu
                        is_branch = 0;
                        is_jump = 0;
                        mem_width = 0;          // doesn't matter since no memory operation
                        mem_write_enable = 0;
                        alu_op = `SLTU;
                        alu_input_config = 1;        // rs1 + rs2
                        imm_sel = 0;            // doesnt matter since no immediate
                    end
                    3'b100: begin
                        // XOR
                        reg_write_enable = 1;
                        result_src = 0;         // alu
                        is_branch = 0;
                        is_jump = 0;
                        mem_width = 0;          // doesn't matter since no memory operation
                        mem_write_enable = 0;
                        alu_op = `XOR;
                        alu_input_config = 1;        // rs1 + rs2
                        imm_sel = 0;            // doesnt matter since no immediate
                    end
                    3'b101: begin
                        case (instr[31:25])
                            default: begin
                                // ??
                                reg_write_enable = 0;
                                result_src = 0;         // alu
                                is_branch = 0;
                                is_jump = 0;
                                mem_width = 0;          // doesn't matter since no memory operation
                                mem_write_enable = 0;
                                alu_op = `NOP;          // ALU does nothing
                                alu_input_config = 0;        // doesnt matter since NOP
                                imm_sel = 0;            // imm_i
                            end
                            7'b0000000: begin
                                // SRL
                                reg_write_enable = 1;
                                result_src = 0;         // alu
                                is_branch = 0;
                                is_jump = 0;
                                mem_width = 0;          // doesn't matter since no memory operation
                                mem_write_enable = 0;
                                alu_op = `SRL;
                                alu_input_config = 1;        // rs1 + rs2
                                imm_sel = 0;            // doesnt matter since no immediate
                            end
                            7'b0100000: begin
                                // SRA
                                reg_write_enable = 1;
                                result_src = 0;         // alu
                                is_branch = 0;
                                is_jump = 0;
                                mem_width = 0;          // doesn't matter since no memory operation
                                mem_write_enable = 0;
                                alu_op = `SRA;
                                alu_input_config = 1;        // rs1 + rs2
                                imm_sel = 0;            // doesnt matter since no immediate
                            end
                        endcase
                    end
                    3'b110: begin
                        // OR
                        reg_write_enable = 1;
                        result_src = 0;         // alu
                        is_branch = 0;
                        is_jump = 0;
                        mem_width = 0;          // doesn't matter since no memory operation
                        mem_write_enable = 0;
                        alu_op = `OR;
                        alu_input_config = 1;        // rs1 + rs2
                        imm_sel = 0;            // doesnt matter since no immediate
                    end
                    3'b111: begin
                        // AND
                        reg_write_enable = 1;
                        result_src = 0;         // alu
                        is_branch = 0;
                        is_jump = 0;
                        mem_width = 0;          // doesn't matter since no memory operation
                        mem_write_enable = 0;
                        alu_op = `AND;
                        alu_input_config = 1;        // rs1 + rs2
                        imm_sel = 0;            // doesnt matter since no immediate
                    end
                endcase
            end
            7'b0010011: begin
                case (instr[14:12])
                    3'b000: begin
                        // ADDI
                        alu_op = `ADDI;
                        reg_write_enable = 1;
                        result_src = 0;         // alu
                        is_branch = 0;
                        mem_width = 0;          // doesn't matter since no memory operation
                        mem_write_enable = 0;
                        is_jump = 0;
                        alu_input_config = 0;        // rs1 + imm
                        imm_sel = 0;                // imm_i
                    end
                    3'b001: begin
                        // SLLI
                        reg_write_enable = 1;
                        result_src = 0;         // alu
                        is_branch = 0;
                        is_jump = 0;
                        mem_width = 0;          // doesn't matter since no memory operation
                        mem_write_enable = 0;
                        alu_op = `SLLI;
                        alu_input_config = 0;        // rs1 + imm
                        imm_sel = 0;            // imm_i
                    end
                    3'b010: begin
                        // SLTI
                        reg_write_enable = 1;
                        result_src = 0;         // alu
                        is_branch = 0;
                        is_jump = 0;
                        mem_width = 0;          // doesn't matter since no memory operation
                        mem_write_enable = 0;
                        alu_op = `SLTI;
                        alu_input_config = 0;        // rs1 + imm
                        imm_sel = 0;            // imm_i
                    end
                    3'b011: begin
                        // SLTIU
                        reg_write_enable = 1;
                        result_src = 0;         // alu
                        is_branch = 0;
                        is_jump = 0;
                        mem_width = 0;          // doesn't matter since no memory operation
                        mem_write_enable = 0;
                        alu_op = `SLTIU;
                        alu_input_config = 0;        // rs1 + imm
                        imm_sel = 0;            // imm_i
                    end
                    3'b100: begin
                        // XORI
                        reg_write_enable = 1;
                        result_src = 0;         // alu
                        is_branch = 0;
                        is_jump = 0;
                        mem_width = 0;          // doesn't matter since no memory operation
                        mem_write_enable = 0;
                        alu_op = `XORI;
                        alu_input_config = 0;        // rs1 + imm
                        imm_sel = 0;            // imm_i
                    end
                    3'b101: begin
                        case (instr[31:25])
                            default: begin
                                // ??
                                reg_write_enable = 0;
                                result_src = 0;         // alu
                                is_branch = 0;
                                is_jump = 0;
                                mem_width = 0;          // doesn't matter since no memory operation
                                mem_write_enable = 0;
                                alu_op = `NOP;          // ALU does nothing
                                alu_input_config = 0;        // doesnt matter since NOP
                                imm_sel = 0;            // imm_i
                            end
                            7'b0000000: begin
                                // SRLI
                                reg_write_enable = 1;
                                result_src = 0;         // alu
                                is_branch = 0;
                                is_jump = 0;
                                mem_width = 0;          // doesn't matter since no memory operation
                                mem_write_enable = 0;
                                alu_op = `SRLI;
                                alu_input_config = 0;        // rs1 + imm
                                imm_sel = 0;            // imm_i
                            end
                            7'b0100000: begin
                                // SRAI
                                reg_write_enable = 1;
                                result_src = 0;         // alu
                                is_branch = 0;
                                is_jump = 0;
                                mem_width = 0;          // doesn't matter since no memory operation
                                mem_write_enable = 0;
                                alu_op = `SRAI;
                                alu_input_config = 0;        // rs1 + imm
                                imm_sel = 0;            // imm_i
                            end
                        endcase
                    end
                    3'b110: begin
                        // ORI
                        reg_write_enable = 1;
                        result_src = 0;         // alu
                        is_branch = 0;
                        is_jump = 0;
                        mem_width = 0;          // doesn't matter since no memory operation
                        mem_write_enable = 0;
                        alu_op = `ORI;
                        alu_input_config = 0;        // rs1 + imm
                        imm_sel = 0;            // imm_i
                    end
                    3'b111: begin
                        // ANDI
                        reg_write_enable = 1;
                        result_src = 0;         // alu
                        is_branch = 0;
                        is_jump = 0;
                        mem_width = 0;          // doesn't matter since no memory operation
                        mem_write_enable = 0;
                        alu_op = `ANDI;
                        alu_input_config = 0;        // rs1 + imm
                        imm_sel = 0;            // imm_i
                    end
                endcase
            end
            7'b0000011: begin
                // LOAD
                reg_write_enable = 1;
                result_src = 1;         // mem
                is_branch = 0;
                is_jump = 0;
                mem_width = instr[14:12];   // the width of the memory operation is encoded in its funct3 bits
                mem_write_enable = 0;
                alu_op = `LOAD;
                alu_input_config = 0;        // rs1 + imm
                imm_sel = 0;            // imm_i
            end
            7'b0100011: begin
                // STORE
                reg_write_enable = 0;
                result_src = 1;         // mem
                is_branch = 0;
                is_jump = 0;
                mem_width = instr[14:12];
                mem_write_enable = 1;
                alu_op = `STORE;
                alu_input_config = 0;        // rs1 + imm
                imm_sel = 4;            // imm_s
            end
            7'b1100011: begin
                case (instr[14:12])
                    3'b000: begin
                        // BEQ
                        reg_write_enable = 0;
                        result_src = 0;         // alu (doesn't matter)
                        is_branch = 1;
                        is_jump = 0;
                        mem_width = 0;          // doesn't matter since no memory operation
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
                        mem_width = 0;          // doesn't matter since no memory operation
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
                        mem_width = 0;          // doesn't matter since no memory operation
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
                        mem_width = 0;          // doesn't matter since no memory operation
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
                        mem_width = 0;          // doesn't matter since no memory operation
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
                        mem_width = 0;          // doesn't matter since no memory operation
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
                        mem_width = 0;          // doesn't matter since no memory operation
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
                mem_width = 0;          // doesn't matter since no memory operation
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
                mem_width = 0;          // doesn't matter since no memory operation
                mem_write_enable = 0;
                alu_op = `JAL;          // ALU does nothing
                alu_input_config = 0;        // doesnt matter
                imm_sel = 2;            // imm_j
            end
            7'b0110111: begin
                // LUI
                reg_write_enable = 1;
                result_src = 0;         // alu
                is_branch = 0;
                is_jump = 0;
                mem_width = 0;          // doesn't matter since no memory operation
                mem_write_enable = 0;
                alu_op = `LUI;
                alu_input_config = 0;        // rs1 + imm
                imm_sel = 1;            // imm_u
            end
            7'b0010111: begin
                // AUIPC
                reg_write_enable = 1;
                result_src = 0;         // alu
                is_branch = 0;
                is_jump = 0;
                mem_width = 0;          // doesn't matter since no memory operation
                mem_write_enable = 0;
                alu_op = `AUIPC;
                alu_input_config = 0;        // rs1 + imm
                imm_sel = 1;            // imm_u
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
                        mem_width = 0;          // doesn't matter since no memory operation
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
                mem_width = 0;          // doesn't matter since no memory operation
                mem_write_enable = 0;
                alu_op = `NOP;          // ALU does nothing
                alu_input_config = 0;        // doesnt matter since NOP
                imm_sel = 0;            // imm_i
            end
        endcase
    end

endmodule