# Introduction

some notes about the motivation of this project

### Scope

After some consideration, this is the scope of the project.
As far as ISA goes, we want ***RV32I*** and the ***M extension***, which is not minimal, but still fairly simple to implement.

Furthermore, the execution should be ***pipelined. 5 stages*** because that's very typical for RISC architectures. (IF ID EX MA WB)

If the above is implemented sufficiently and if time still permits, implement some sort of ***memory interface*** for either FPGA (BRAM) or ASIC (DDR, AXI, AHB, SRAM) synthesis, as well as VERY ***basic caching*** (I-Cache and D-Cache, incl. adequate placement policies, replacement policies and eviction policies). If project complexity increases unreasonably, move these two points into a new project.

### Considerations n stuff

[RISC-V ISA Specs](https://github.com/riscv/riscv-isa-manual/releases/download/riscv-isa-release-2c2a793-2025-03-07/riscv-unprivileged.pdf) are used, obviously

- Use Verilator 5.019 for simulation
- For now, Data and Instruction memories have been implemented as byte-addressable. However, RISC-V allows only for aligned accesses on IMem (and I could choose to do the same for DMem). So I will need to implement an exception for unallowed unaligned accesses.

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

for now, fetching is literally as simple as just instantiating the instr_mem module as well as a PC. This is a naive solution, and so far no special mechanisms such as Branch Prediction are planned, therefore it will suffice for my intended scope.

In a later iteration, it became necessary to receive additional signals from the execute stage: a target PC as well as a signal to indicate whether or not to use the target PC instead of the normally incremented next PC (i.e. signals to enable jumps/branches).  
Also, output the fetched PC as well as the next PC to be loaded (for access to PC down the line).

# Instruction Decode

After receiving 32 bits of instruction, we need to decode. This means mapping opcode + funct bits to our internal encoding (s. above) and other control signals. We realize this via nested case statements, something like this:

```verilog
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
```

In later iterations, this decoding is encapsulated in a decode control unit - reading the instruction bits and outputting all relevant control signals for this and all further iterations.  
This stage will also subsume the register file (instead of the Execute stage as I had planned initially).

### The Register File

for starters, I implemented a simple register file with 32x full word (32 bit) registers - with 2 read ports and 1 write port.  
For simulation purposes, I added an `initial` block which reads a file containing initial values for all registers.  
It is important to make sure that read accesses to `x0` always return 0, and that it cannot be overwritten.

# Execute 

initially, the only functional unit inside the Execute Unit should be an ALU. The Execute Unit does many things, but to just get it up and running, ~~I will just have it fetch data from the register file,~~ execute the instruction on the ALU, and output the result.

The Execute unit also has to handle the calculation of jump targets and conditions.

### The ALU

for starters, let's have a basic ALU that implements *some* instructions. Out of the 40 instructions in the base ISA, the following are being implemented:

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

In later iterations, the ALU also took on the role of calculating the conditions for the branch instructions (BEQ/BNE/BLT/BLTU/BGE/BGEU)


### Execute Unit

for now, the Execute Unit is a very simple module that takes in the decoded operator from the Decode Unit and drives the inputs to the correct functional unit, which as of now, is *only* the ALU.

In a later iteration, the calculation of branch/jump conditions and targets is also implemented in the exec unit.

# Memory Access

The stage following the Execute Stage is the Memory Access. Before implementing the unit itself, I need to spoof some sort of data memory, similar to what I did with the instruction memory before.

### Data Memory

the data memory will look exactly like the instruction memory, except it will be 2 MB instead of just 4 KB.

### The MemAcc Unit

Very simple for now: just encapsulate the data memory and route input/output signals.
Note that we forward the read memory AS WELL AS the forwarded result from the exec stage, because the selection of the appropriate result (i.e. whether the instruction was a load or not) will only be determined in the following write-back stage.


# Write Back

The Write-Back stage takes a target register (decoded previously in the decode stage) and writes the instruction's result into it. The 'result' is determined by the type of instruction: for jumps/branches, it is the current PC + 4; for load instructions, it is data loaded during the memory access stage; for every other kind of instructions, it is some data calculated during the execute stage.

It needs to connect to the decode stage in order to access the register file.


# Datapath / Pipeline Control

We need a unit to subsume all pipeline stage units and coordinate their pipelined execution, i.e. each unit should take 1 cycle to complete, and all inputs/outputs need to be routed correctly.


In a later iteration, all the pipeline register logic is refactored into the stages themselves, which means the datapath now only contains the interconnecting wires and the modules.

- [ ] TODO: Datapath illustration here

# Hazard Unit

With that last part (the datapath unit) out of the way, the processor works as intended!  
...almost. Hazards completely break the machine state and lead to unpredictable/unintended/weird results. This of course is to be expected, since we currently run a pipelined execution model with no special treatment of data hazards. We therefore have to implement hazard handling in a special part of the hardware, the *hazard unit*.

The core principle is the following: The hazard unit tracks which registers are written to by instructions that are currently in stages 4 or 5 (MA/WB) and compares them against all registers whose values are currently being used in stage 3 (EX). If there is a match, that means that the value of the instruction currently in stage 4 or 5 should be forwarded back to stage 3 for usage immediately, so the instruction in stage 3 uses the correct value for its computation. 

- [ ] TODO: maybe an illustration of the adjusted datapath?

# Latency Considerations 

Down the line, the processor will be extended by a real memory controller as well as a MUL/DIV unit. However, both MUL/DIV and real memory accesses are *multi-cycle operations*. Currently, the pipeline operates on the premise that each stage takes exactly 1 cycle to complete. Therefore the pipeline design needs to be adjusted to account for these multi-cycle operations. The most fundamental change that I need to make here is to allow for *pipeline stalls*. In other words: when a respective signal is driven high, all pipeline stage units should pause and hold their current state until the signal becomes low again.  
More advanced pipeline implementations additionally employ techniques such as instruction reordering to hide the resulting latencies (i.e. the cycles in which no instructions are being processed due to the stall), however for complexity's sake, I choose not to do so.

The implementation is fairly straight-forward: Establish a single signal (like a bus), supplied to every pipeline stage, and have the stages react to that signal, i.e. stop execution when it is high.

# Problems I ran into

- When implementing Datapath:
    - pipelining wasn't clock-synchronized, data just fell through and processed immediately
        - **solution**: insert latch between each pipeline stage unit; in Verilog, this meant save each output in a register on posedge clock
    - some pipeline stage units (more precisely, decode and execute) took longer than just 1 cycle
        - **solution**: change sensitivity list in those units from listening to posedge clock to combinational (on change of any of the input signals) -> synthesize their outputs as wires (not regs)
- When implementing Data/Instruction Memory Spoofs:
    - RISC-V only allows aligned access for IMem, and aligned OR unaligned access for DMem. When implementing the memory spoofs, I originally implemented the memory arrays as X lines of 32bit words. This however wouldn't do, because that'd mean the memory had to be accessed with addresses >> 2. 
        - **solution**: I opted to define the arrays as X*4 lines of 8bit bytes (i.e. ```reg [31:0] arr [1023:0]``` becomes ```reg [7:0] arr [4095:0]```). Alternatively, it would've been possible to access the array with ```address >> 2``` inside the memory module.
- When implementing the Memory Access Stage:
    - The Memory Spoofs access memory in 1 cycle, but that will NOT be the case with real memory. Therefore, I WILL need to implement stalling of the stages IF, ID, EX upon MA stall later on.
- when trying to implement writeback stage:
    - Demuxing the value to be written (either from loaded memory or from ALU result) proves difficult bc it accesses values from earlier stages (exec) which have not been forwarded per-cycle to this last stage in my current design (exec only goes to MA, then gets overwritten by next instr.)
        - **solution**: we need to forward all data from stage to stage -> reworking of pipeline registers needed!
- reworking pipeline registers:
    - the current structure is very unflexible and unmodular, so take this chance to rework the pipeline register logic into the modules themselves as well!
    - also increase modularity in general wherever possible: i.e. mux module, pc module, pc adder, decode_control_unit, ...
    - make it so every stage outputs not only its own output to the next stage, but also info it received from previous stages
- after implementing the datapath:
    - pipeline works as intended! however, hazards completely break the machine state
        - **solution**: implement a Hazard Unit