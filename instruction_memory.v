module instruction_memory (
    input  wire [31:0] address,
    output wire [31:0] instruction
);

    reg [31:0] memory [0:255];


    initial begin
        // 0x00: addi x1, x0, 10
        memory[0] = 32'h00a00093;

        // 0x04: ecall
        memory[1] = 32'h00000073;

        // 0x08: addi x2, x0, 42
        memory[2] = 32'h02a00113;

        // 0x0c: jal x0, 0
        memory[3] = 32'h0000006f;

        // 0x100: csrr x5, mepc
        memory[64] = 32'h341022f3;

        // 0x104: addi x5, x5, 4
        memory[65] = 32'h00428293;

        // 0x108: csrw mepc, x5
        memory[66] = 32'h34129073;

        // 0x10c: mret
        memory[67] = 32'h30200073;
    end

    assign instruction =
        memory[address[9:2]];

endmodule
