`include "src/datapath.v"

module datapath_tb();

    reg clk;
    wire [31:0] out;

    datapath datapath(
        .clk(clk),
        .out(out)
    );


    integer i;
    initial begin
        $dumpfile("datapath_tb.vcd");
        $dumpvars();
        clk = 0;

        for(i = 0; i < 15; i++) begin
            $display("CYCLE: %d, reg[1]: %d, reg[2]: %d, reg[3]: %d, reg[4]: %d, reg[5]: %d, reg[6]: %d", i, $signed(datapath.decode.rf.regs[1]), $signed(datapath.decode.rf.regs[2]), $signed(datapath.decode.rf.regs[3]), $signed(datapath.decode.rf.regs[4]), $signed(datapath.decode.rf.regs[5]), $signed(datapath.decode.rf.regs[6])); 
            #10;
        end

        $finish;
    end

    always begin
        #5 clk = ~clk;
    end
endmodule