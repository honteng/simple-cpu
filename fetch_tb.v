`timescale 1ns/1ps

module fetch_tb;

    reg clk;
    reg reset;

    wire [31:0] pc;
    wire [31:0] instruction;

    program_counter pc0 (
        .clk(clk),
        .reset(reset),
        .pc(pc)
    );

    instruction_memory imem (
        .address(pc),
        .instruction(instruction)
    );

    always #5 clk = ~clk;

    initial begin
        $dumpfile("fetch.vcd");
        $dumpvars(0, fetch_tb);

        clk = 0;
        reset = 1;

        // 最初のposedgeでPCを0にする
        #6;

        reset = 0;

        #1;
        $display("PC=%d instruction=%h", pc, instruction);

        #10;
        $display("PC=%d instruction=%h", pc, instruction);

        #10;
        $display("PC=%d instruction=%h", pc, instruction);

        #10;
        $display("PC=%d instruction=%h", pc, instruction);

        $finish;
    end

endmodule