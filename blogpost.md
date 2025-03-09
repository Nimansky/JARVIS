# Introduction

some notes about the motivation of this project

### Scope

After some consideration, this is the scope of the project.
As far as ISA goes, we want ***RV32I*** and the ***M extension***, which is not minimal, but still fairly simple to implement.

Furthermore, the execution should be ***pipelined. 5 stages*** because that's very typical for RISC architectures. (IF ID EX MA WB)

If the above is implemented sufficiently and if time still permits, implement some sort of ***memory interface*** for either FPGA (BRAM) or ASIC (DDR, AXI, AHB, SRAM) synthesis, as well as VERY ***basic caching*** (I-Cache and D-Cache, incl. adequate placement policies, replacement policies and eviction policies). If project complexity increases unreasonably, move these two points into a new project.

### Considerations n stuff

[RISC-V ISA Specs](https://github.com/riscv/riscv-isa-manual/releases/download/riscv-isa-release-2c2a793-2025-03-07/riscv-unprivileged.pdf) are used, obviously

Use Verilator 5.019 for simulation

...

# Instruction Fetch

### Instruction Memory

in order to perform an instruction fetch, there needs to be an instruction memory to fetch from. for simulation purposes, I will implement pseudo-ROM containing some instructions to be executed. it's 4KB with cycle-aligned read access, and it loads given programs at simulation time.

```verilog
module instr_mem(
    input clk,
    output [31:0] data_out,
    input [31:0] addr
);

    reg [31:0] mem [1023:0]; // 4 KB instr mem

    initial begin
        $readmemh("init/sample_prog0.mem", mem); // executes 'addi rs1, rs1, 1000' 5 times
    end

    always @ (posedge clk) begin
        data_out <= mem[addr[9:0]];
    end

endmodule
```

### Fetching

for now, fetching is literally as simple as just instantiating the instr_mem module and forwarding the requested pc as well as the clock. This is the naive solution, and so far no special mechanisms such as Branch Prediction are planned, so I will continue with this approach until I run into further problems which require further refinement.

```verilog
`include "src/instr_mem.v"

module instr_fetch(
    input clk,
    input [31:0] pc,
    output [31:0] instr
);

    // for now nothing needs to be done besides fetching an instruction
    instr_mem im (
        .clk(clk),
        .addr(pc),
        .data_out(instr)
    );

endmodule
```

# Instruction Decode

After receiving 32 bits of instruction, we need to decode. In our (so far very primitive) case, this means mapping opcode + funct bits to our internal encoding (s. above). We realize this via nested case statements.

```verilog
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
    output reg [31:0] imm
);

    always @ (posedge clk) begin
        case (instr[6:0])
            7'b0110011: begin
                case (instr[14:12]) /* -- FUNCT3 --*/
                    3'b000: begin
                        case (instr[31:25]) /* -- FUNCT7 --*/
                            7'b0000000: ...  // ADD
                            7'b0100000: ... // SUB
                        endcase
                    end
                    3'b001: ... // SLL
                    3'b010: ... // SLT
                    3'b011: ... // SLTU
                    3'b100: ... // XOR
                    3'b101: begin
                        case (instr[31:25]) /* -- FUNCT7 --*/
                            7'b0000000: ... // SRL
                            7'b0100000: ... // SRA
                        endcase
                    end
                    3'b110: ... // OR
                    3'b111: ... // AND
                endcase
            end
            7'b0010011: begin
                case (instr[14:12]) /* -- FUNCT3 --*/
                    3'b000: ... // ADDI
                    3'b001: ... // SLLI
                    3'b010: ... // SLTI
                    3'b011: ... // SLTIU
                    3'b100: ... // XORI
                    3'b101: begin
                        case (instr[31:25]) /* -- FUNCT7 --*/
                            7'b0000000: ... // SRLI
                            7'b0100000: ... // SRAI
                        endcase
                    end
                    3'b110: ... // ORI
                    3'b111: ... // ANDI
                endcase
            end
            7'b0000011: begin
                case (instr[14:12]) /* -- FUNCT3 --*/
                    3'b000: ... // LB
                    3'b001: ... // LH
                    3'b010: ... // LW
                    3'b100: ... // LBU
                    3'b101: ... // LHU
                endcase
            end
            7'b0100011: begin
                case (instr[14:12]) /* -- FUNCT3 --*/
                    3'b000: ... // SB
                    3'b001: ... // SH
                    3'b010: ... // SW
                endcase
            end
            7'b1100011: begin
                case (instr[14:12]) /* -- FUNCT3 --*/
                    3'b000: ... // BEQ
                    3'b001: ... // BNE
                    3'b100: ... // BLT
                    3'b101: ... // BGE
                    3'b110: ... // BLTU
                    3'b111: ... // BGEU
                endcase
            end
            7'b1100111: ... // JALR
            7'b1101111: ... // JAL
            7'b0110111: ... // LUI
            7'b0010111: ... // AUIPC
            7'b1110011: begin
                case (instr[14:12]) /* -- FUNCT3 --*/
                    12'h000: ... // ECALL
                    12'h001: ... // EBREAK
                endcase
            end
        endcase
    end

endmodule;
```

# Execute 

### The ALU

for starters, let's implement a basic ALU that implements *some* instructions. Out of the 40 instructions in the base ISA, the following are being implemented:

* **ADDI** (add immediate): add 12 bit signed val to register val; ignore arithmetic overflow
* **ANDI/ORI/XORI**: perform logical op on reg val and 12 bit signed val
* **ADD**: add vals of 2 regs; ignore overflows
* **AND/OR/XOR**: perform logical ops on 2 reg vals
* **SUB**: sub vals of 2 regs; ignore overflows

right at the beginning, when designing the ALU, I wondered: how do I even encode the operations for the verilog module? i could use an internal encoding (smth like an enum), then i'd have to convert between opcode+funct bits to internal enum encoding, or i could use the regular opcode+funct bits as input, but a) those have variable length (since not all funct bits are always present) and b) MOST of them are not needed for the ALU anyway (those instr. go to other units), which means wasted bandwidth  
   => idea: use an internal enum; so count how many instructions.  
Since Enums are a SystemVerilog extensions, just use constants aka. macro defines for each instruction (takes a total of 6 bits for 35 instructions in base ISA + 4 for M extension)  
the definitions look like this:
```verilog
`define ADDI 6'b000000
`define SLTI 6'b000001
`define SLTIU 6'b000010
`define ANDI 6'b000011
`define ORI 6'b000100
`define XORI 6'b000101
`define SLLI 6'b000110
`define SRLI 6'b000111
`define SRAI 6'b001000
...
```

After that worked, I implemented the rest of the ALU operations, which were:
* SLTIU and SLTU (store less than [immediate] unsigned)
* SLT and SLTI (store less than [immediate] signed)
* SLL and SLLI (Shift Left Logical [immediate])
* SRL and SRLI (Shift Right Logical [immediate])
* SRA and SRAI (Shift Right Arithmetic [immediate])

This is what `alu.v` looks like so far:
```verilog
`include "src/constants.v"

module alu
(
    input clk,
    input [31:0] a,
    input [31:0] b,
    input [5:0] alu_op,
    output reg [31:0] result
);

always @ (posedge clk) begin
    case (alu_op)
        `ADDI,
        `ADD: result <= a + b;
        `SLTIU,
        `SLTU: result <= (a < b) ? 1 : 0;
        `SLT,
        `SLTI: result <= ($signed(a) < $signed(b)) ? 1 : 0;
        `ANDI,
        `AND: result <= a & b;
        `ORI,
        `OR: result <= a | b;
        `XORI,
        `XOR: result <= a ^ b;
        `SUB: result <= a - b;
        `SLL,
        `SLLI: result <= a << b[4:0];
        `SRL,
        `SRLI: result <= a >> b[4:0];
        `SRA,
        `SRAI: result <= {a[31], a[31:1]};
        default: result <= 0;
    endcase
end

endmodule
```

### The Register File

for starters, I implemented a simple register file with 32x full word (32 bit) registers - with one separate read and write port each. In the future, there could be more ports, *potentially*. The code looks like this:

```verilog
module regfile 
(
    input clk,
    input [4:0] read_addr,
    input [31:0] data_in,
    input write_enable,
    input [4:0] write_addr,
    output [31:0] data_out
);

    reg [31:0] regs [31:0];

    // for simulation only
    initial begin

        // set all regs to 0
        $readmemh("init/regfile.mem", regs);
    end

    always @ (posedge clk) begin
        if (write_enable) begin
            regs[write_addr] <= data_in;
        end
    end
    
    assign data_out = regs[read_addr];
    
endmodule
```
