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

        // 0x0c: lw x3, 2(x1), misaligned word access
        memory[3] = 32'h0020a183;

        // 0x10: addi x4, x0, 77
        memory[4] = 32'h04d00213;

        // 0x14: jal x0, 0, self loop
        memory[5] = 32'h0000006f;

        // 0x100: csrrs x5, mepc, x0 (csrr x5, mepc)
        memory[64] = 32'h341022f3;

        // 0x104: addi x5, x5, 4
        memory[65] = 32'h00428293;

        // 0x108: csrrw x0, mepc, x5 (csrw mepc, x5)
        memory[66] = 32'h34129073;

        // 0x10c: mret
        memory[67] = 32'h30200073;
    end

    assign instruction =
        memory[address[9:2]];

endmodule
