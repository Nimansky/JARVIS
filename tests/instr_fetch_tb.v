`include "src/instr_fetch.v"

module instr_fetch_tb();

    reg clk;
    wire [31:0] fetch_to_decode_pc, fetch_to_decode_next_pc, fetch_to_decode_instr;

    instr_fetch instr_fetch(
        .clk(clk),
        .pc_target_exec(),          // needs input from exec
        .pc_src_exec(1),            // 1 means PC should be incremented by 4 - needs output from exec
        .instr_decode(fetch_to_decode_instr),
        .pc_decode(fetch_to_decode_pc),
        .next_pc_decode(fetch_to_decode_next_pc)
    );

    integer i;
    initial begin
        $dumpfile("instr_fetch_tb.vcd");
        $dumpvars();
        clk = 0;

        for (i = 0; i < 8; i++) begin
            $display("CYCLE %d: addr = %h, data_out = %h", i, fetch_to_decode_pc, fetch_to_decode_instr);
            #10;
        end

        $finish;
    end

    always begin
        #5 clk = ~clk;
    end

endmodule