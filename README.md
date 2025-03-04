# JARVIS

**JARVIS** (*Just Another RISC-V Implementation Study*) is supposed to be a fully functional implementation of a RISC-V processor (mainly) in **SystemVerilog**.

## Scope

The implementation should consist of at least:
- RV32I
- M extension
- 5 stage pipelined execution (IF ID EX MA WB)
- Some sort of (minimal) memory interface
- VERY basic caching (I-Cache and D-Cache, incl. adequate placement policies, replacement policies and eviction policies)

## Outline

#### Components
A rough collection of components that need to be implemented:
- 1 ALU
- 1 LSU
- 1 MUL unit
- Register File (32 regs, check with spec)
- I-Cache and D-Cache

#### Considerations
Additional things to be considered:
- Hazard handling
    - Stalling or branch prediction? data forwarding or hazard detection? how about shared resources?
- Exception handling
- Privilege modes: implement user mode or not?
