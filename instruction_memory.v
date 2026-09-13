module instruction_memory (
    input  wire [31:0] address,
    output wire [31:0] instruction
);

    reg [31:0] memory [0:255];


    initial begin
        // addi x1, x0, 100
        memory[0] = 32'h06400093;

        // addi x2, x0, 42
        memory[1] = 32'h02a00113;

        // sw x2, 0(x1): address 100 is word-aligned
        memory[2] = 32'h0020a023;

        // lw x3, 0(x1): aligned load
        memory[3] = 32'h0000a183;

        // lw x4, 2(x1): address 102 is misaligned
        memory[4] = 32'h0020a203;

        // nop
        memory[5] = 32'h00000013;

        // 0x20: addi x5, x0, 42
        memory[8] = 32'h02a00293;

        // 0x100: mret
        memory[64] = 32'h30200073;
    end

    assign instruction =
        memory[address[9:2]];

endmodule
