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

# The ALU

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