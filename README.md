# JARVIS

**JARVIS** (*Just Another RISC-V Implementation Study*) is supposed to be a fully functional implementation of a RISC-V processor (mainly) in **SystemVerilog**.

## Scope

The goals of the implementation are as follows:
- RV32I
- M extension
- VERY basic caching (I-Cache and D-Cache, incl. adequate placement policies, replacement policies and eviction policies)
- 5 stage pipelined execution (IF ID EX MA WB)
- Some sort of memory interface for FPGA (BRAM) or ASIC (DDR, AXI, AHB, SRAM) memory

## Outline

#### Components
A rough collection of components that need to be implemented:
- 1 ALU
- 1 LSU
- 1 MUL/DIV unit
- Register File (32 regs, check with spec)
- Instruction Fetch Stage
- Instruction Decode Stage
- Pipeline Control Unit (branching, stalling, forwarding; pipeline overhead)
- I-Cache and D-Cache

#### Considerations
Additional things to be considered:
- Hazard handling
    - Stalling or branch prediction? data forwarding or hazard detection? how about shared resources?
- Exception handling
- Privilege modes: implement user mode or not?
