`include "src/constants.v"

module instr_decode(
    input clk,
    input [31:0] instr,
    output reg [5:0] op,
    output reg rs1_v,
    output reg [4:0] rs1,
    output reg rs2_v,
    output reg [4:0] rs2,
    output reg [4:0] rd,
    output reg imm_v,
    output reg [31:0] imm,
    output reg load_store_instr
);

    always @ (*) begin
        load_store_instr = 0;
        case (instr[6:0])
            7'b0110011: begin
                case (instr[14:12])
                    3'b000: begin
                        case (instr[31:25]) 
                            default: begin
                                // ??
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
                        op = `ADDI;
                        rs1_v = 1;
                        rs1 = instr[19:15];
                        rs2_v = 0;
                        rs2 = 0;
                        rd = instr[11:7];
                        imm_v = 1;
                        imm = {{20{instr[31]}}, instr[31:20]};
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
                load_store_instr = 1;
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
                    end
                endcase
            end
            7'b1100011: begin
                case (instr[14:12])
                    3'b000: begin
                        // BEQ
                    end
                    3'b001: begin
                        // BNE
                    end
                    3'b100: begin
                        // BLT
                    end
                    3'b101: begin
                        // BGE
                    end
                    3'b110: begin
                        // BLTU
                    end
                    3'b111: begin
                        // BGEU
                    end
                    default: begin
                        // ??
                    end
                endcase
            end
            7'b1100111: begin
                // JALR
            end
            7'b1101111: begin
                // JAL
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
                    end
                endcase
            end
            default: begin
                // ??
            end
        endcase
    end

endmodule;