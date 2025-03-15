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
- For now, Data and Instruction memories have been implemented as byte-addressable. However, RISC-V allows only for aligned accesses. So I will need to implement an exception for unaligned accesses.

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

In a later iteration, it becomes necessary to receive additional signals from the execute stage: a target PC as well as a signal to indicate whether or not to use the target PC instead of the normally incremented current PC (i.e. signals to enable jumps/branches).  
Also, output the fetched PC as well as the next PC to be loaded (for access to PC down the line).

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

In later iterations, this decoding is encapsulated in a decode control unit - reading the instruction bits and outputting all relevant control signals for this and all further iterations.  
This stage will also subsume the register file (instead of the Execute stage as I had planned initially).

### The Register File

for starters, I implemented a simple register file with 32x full word (32 bit) registers - with 2 read ports and 1 write port. The code looks like this:

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

In later iterations, the ALU also took on the role of calculating the conditions for the branch instructions (BEQ/BNE/BLT/BLTU/BGE/BGEU)


### Execute Unit

for now, the Execute Unit is a very simple module that takes in the decoded operator from the Decode Unit and drives the inputs to the correct functional unit, which as of now, is *only* the ALU.

```verilog
`include "src/constants.v"
`include "src/alu.v"

module exec(
    input clk,
    input [5:0] op,
    input [31:0] in1,
    input [31:0] in2,

    output reg [31:0] out
);

    wire [31:0] res_alu;

    alu alu(
        .clk(clk),
        .a(in1),
        .b(in2),
        .alu_op(op),
        .result(res_alu)
    );

    always @ (*) begin
        case (op)
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
            `SRAI: begin
                out = res_alu;
            end
            default: out = 0;
        endcase
    end

endmodule
```

In a later iteration, the calculation of branch/jump conditions and targets is also implemented in the exec unit.

# Datapath / Pipeline Control

We need a unit to subsume all pipeline stage units and coordinate their pipelined execution, i.e. each unit should take 1 cycle to complete, and all inputs/outputs need to be routed correctly.

```verilog
`include "src/instr_fetch.v"
`include "src/instr_decode.v"
`include "src/regfile.v"
`include "src/exec.v"

module datapath (
    input clk,
    output [31:0] out
);

    reg [31:0] pc = 0;

    // concept for all stages:
    // wire for all outputs
    // store results in regs at each posedge clk

    wire [31:0] fetch_instr_out;

    instr_fetch instr_fetch(
        .clk(clk),
        .pc(pc),
        .instr_out(fetch_instr_out)
    );

    reg [31:0] fetch_to_decode_instr_out;

    always @ (posedge clk) begin
        fetch_to_decode_instr_out <= fetch_instr_out;
    end

    wire [5:0] decode_op;
    wire decode_rs1_v;
    wire [4:0] decode_rs1;
    wire decode_rs2_v;
    wire [4:0] decode_rs2;
    wire [4:0] decode_rd;
    wire decode_imm_v;
    wire [31:0] decode_imm;

    instr_decode instr_decode(
        .clk(clk),
        .instr(fetch_to_decode_instr_out),
        .op(decode_op),
        .rs1_v(decode_rs1_v),
        .rs1(decode_rs1),
        .rs2_v(decode_rs2_v),
        .rs2(decode_rs2),
        .rd(decode_rd), 
        .imm_v(decode_imm_v),
        .imm(decode_imm)
    );

    reg [5:0] decode_to_exec_op;
    reg decode_to_regfile_rs1_v;
    reg [4:0] decode_to_regfile_rs1;
    reg decode_to_regfile_rs2_v;
    reg [4:0] decode_to_regfile_rs2;
    reg [4:0] decode_to_exec_rd;
    reg decode_to_exec_imm_v;
    reg [31:0] decode_to_exec_imm;


    // additional logic in decode stage: access regfile and read values if necessary
    wire [31:0] regfile_to_exec_rs1_data;
    wire [31:0] regfile_to_exec_rs2_data;

    regfile rf(
        .clk(clk),
        .read_addr1(decode_to_regfile_rs1),
        .read_addr2(decode_to_regfile_rs2),
        .data_in(),         // later driven by WRITEBACK unit
        .write_enable(),    // later driven by WRITEBACK unit
        .write_addr(),      // later driven by WRITEBACK unit
        .data_out1(regfile_to_exec_rs1_data),
        .data_out2(regfile_to_exec_rs2_data)
    );

    reg [31:0] exec_in1;
    reg [31:0] exec_in2;

    always @ (posedge clk) begin
        decode_to_exec_op = decode_op;
        decode_to_regfile_rs1_v = decode_rs1_v;
        decode_to_regfile_rs1 = decode_rs1;
        decode_to_regfile_rs2_v = decode_rs2_v;
        decode_to_regfile_rs2 = decode_rs2;
        decode_to_exec_rd = decode_rd;
        decode_to_exec_imm_v = decode_imm_v;
        decode_to_exec_imm = decode_imm;
    end


    // conditional assignment of exec unit inputs; either reg values or immediate values
    always @ (*) begin
        if (decode_to_regfile_rs1_v && decode_to_regfile_rs2_v) begin
            exec_in1 = regfile_to_exec_rs1_data;
            exec_in2 = regfile_to_exec_rs2_data;
        end else if (decode_to_regfile_rs1_v && decode_to_exec_imm_v) begin
            exec_in1 = regfile_to_exec_rs1_data;
            exec_in2 = decode_to_exec_imm;
        end else if (decode_to_regfile_rs2_v && decode_to_exec_imm_v) begin
            exec_in1 = regfile_to_exec_rs2_data;
            exec_in2 = decode_to_exec_imm;
        end else begin
            exec_in1 = 0;
            exec_in2 = 0;
        end
    end
    
    wire [31:0] exec_out;

    exec exec(
        .clk(clk),
        .op(decode_to_exec_op),
        .in1(exec_in1),
        .in2(exec_in2),
        .out(exec_out)
    );

    reg [31:0] exec_to_memacc_out;

    always @ (posedge clk) begin
        exec_to_memacc_out <= exec_out;
    end


    // exec is last stage as of now (MA and WB stages not implemented yet)
    assign out = exec_to_memacc_out;


    // new instruction each cycle (no abort condition yet, no branch support yet)
    always @ (posedge clk) begin
        pc <= pc + 1;
    end

endmodule
```

# Memory Access

The stage following the Execute Stage is the Memory Access. Before implementing the unit itself, I need to spoof some sort of data memory, similar to what I did with the instruction memory before.

### Data Memory

the data memory will look exactly like the instruction memory, except it will be 2 MB instead of just 4 KB.

```verilog
module data_mem (
    input clk,
    input [31:0] addr,
    input write_enable,
    input [31:0] data_in,
    output reg [31:0] data_out
);

    reg [7:0] mem [2097151:0]; // 2 MB data mem

    initial begin
        integer i;
        for(i = 0; i < 2097152; i = i + 1) begin
            mem[i] = i[7:0];
        end
    end

    always @ (posedge clk) begin
        if(write_enable) begin
            mem[addr[20:0]] <= data_in[31:24];
            mem[addr[20:0] + 1] <= data_in[23:16];
            mem[addr[20:0] + 2] <= data_in[15:8];
            mem[addr[20:0] + 3] <= data_in[7:0];
        end
    end

    assign data_out = {mem[addr[20:0]], mem[addr[20:0] + 1], mem[addr[20:0] + 2], mem[addr[20:0] + 3]};

endmodule
```

### The MemAcc Unit

Very simple for now: just encapsulate the data memory and route input/output signals.
Note that we forward the read memory AS WELL AS the forwarded result from the exec stage, because the selection of the appropriate result (i.e. whether the instruction was a load or not) will only be determined in the following write-back stage.

```verilog
`include "src/data_mem.v"

module memacc(
    input clk,
    input [31:0] addr,
    input write_enable,
    input [31:0] data_in,
    output reg data_out_v,
    output reg [31:0] data_out
);

    data_mem dm (
        .clk(clk),
        .addr(addr),
        .write_enable(write_enable),
        .data_in(data_in),
        .data_out_v(data_out_v),
        .data_out(data_out)
    );

endmodule
```


# Write Back

The Write-Back stage takes a target register (decoded previously in the decode stage) and writes the instruction's result into it. The 'result' is determined by the type of instruction: for jumps/branches, it is the current PC + 4; for load instructions, it is data loaded during the memory access stage; for every other kind of instructions, it is some data calculated during the execute stage.

It needs to connect to the decode stage in order to access the register file.

```verilog
module writeback(
    input clk,

    input [31:0] exec_data_in,
    input [31:0] mem_data_in,
    input [31:0] next_pc,
    input [1:0] res_src,

    output [31:0] data_out
);

    // this could potentially be a 3-way-mux if that'd be more practical for synthesis 
    assign data_out = res_src == 2'b00 ? exec_data_in : 
                      res_src == 2'b01 ? mem_data_in : 
                      res_src == 2'b10 ? next_pc : 
                      32'h0;    // return 0 if invalid res_src

endmodule
```


# Problems I ran into

- When implementing Datapath:
    - pipelining wasn't clock-synchronized, data just fell through and processed immediately
        - **solution**: insert latch between each pipeline stage unit; in Verilog, this meant save each output in a register on posedge clock
    - some pipeline stage units (more precisely, decode and execute) took longer than just 1 cycle
        - **solution**: change sensitivity list in those units from listening to posedge clock to combinational (on change of any of the input signals)
- When implementing Data/Instruction Memory Spoofs:
    - RISC-V only allows aligned access. When implementing the memory spoofs, I originally implemented the memory arrays as X lines of 32bit words. This however wouldn't do, because that'd mean the memory had to be accessed with addresses >> 2. 
        - **solution**: I opted to define the arrays as X*4 lines of 8bit bytes (i.e. ```reg [31:0] arr [1023:0]``` becomes ```reg [7:0] arr [4095:0]```). Alternatively, it would've been possible to access the array with ```address >> 2``` inside the memory module.
- When implementing the Memory Access Stage:
    - The Memory Spoofs access memory in 1 cycle, but that will NOT be the case with real memory. Therefore, I WILL need to implement stalling of the stages IF, ID, EX upon MA stall later on.
- when trying to implement writeback stage:
    - Demuxing the value to be written (either from loaded memory or from ALU result) proves difficult bc it accesses values from earlier stages (exec) which have not been forwarded per-cycle to this last stage in my current design (exec only goes to MA, then gets overwritten by next instr.)
        - **solution**: we need to forward all data from stage to stage -> reworking of pipeline registers needed!
- reworking pipeline registers:
    - the current structure is very unflexible and unmodular, so take this chance to rework the pipeline register logic into the modules themselves as well!
    - also increase modularity in general wherever possible: i.e. mux module, pc module, pc adder, ...
    - make it so every stage outputs not only its own output to the next stage, but also info it received from previous stages