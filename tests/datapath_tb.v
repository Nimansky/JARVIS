`include "src/datapath.v"

module datapath_tb();

    reg clk;
    reg reset;

    datapath datapath(
        .clk(clk),
        .reset(reset)
    );

    integer i;
    initial begin
        $dumpfile("datapath_tb.vcd");
        $dumpvars();
        reset = 0;
        reset = 1;
        clk = 0;

        for(i = 0; i < 20; i++) begin
            $display("CYCLE: %d, PC: %d, reg[1]: %d, reg[2]: %d, reg[3]: %d, reg[4]: %d, reg[5]: %d, reg[6]: %d, reg[7]: %d", i, datapath.instr_fetch.pc_decode, $signed(datapath.decode.rf.regs[1]), $signed(datapath.decode.rf.regs[2]), $signed(datapath.decode.rf.regs[3]), $signed(datapath.decode.rf.regs[4]), $signed(datapath.decode.rf.regs[5]), $signed(datapath.decode.rf.regs[6]), $signed(datapath.decode.rf.regs[7])); 
            #10;
        end

        $finish;
    end

    always begin
        #5 clk = ~clk;
    end
endmodule