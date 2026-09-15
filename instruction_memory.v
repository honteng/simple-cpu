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

        // 0x0c: ebreak
        memory[3] = 32'h00100073;

        // 0x10: addi x3, x0, 77
        memory[4] = 32'h04d00193;

        // 0x14: jal x0, 0
        memory[5] = 32'h0000006f;

        // 0x100: csrrs x5, mcause, x0
        memory[64] = 32'h342022f3;

        // 0x104: addi x6, x0, 11
        memory[65] = 32'h00b00313;

        // 0x108: beq x5, x6, handle_ecall
        memory[66] = 32'h00628863;

        // 0x10c: addi x6, x0, 3
        memory[67] = 32'h00300313;

        // 0x110: beq x5, x6, handle_ebreak
        memory[68] = 32'h00628863;

        // 0x114: jal x0, advance_mepc
        memory[69] = 32'h0140006f;

        // 0x118: handle_ecall: addi x10, x0, 1
        memory[70] = 32'h00100513;

        // 0x11c: jal x0, advance_mepc
        memory[71] = 32'h00c0006f;

        // 0x120: handle_ebreak: addi x11, x0, 1
        memory[72] = 32'h00100593;

        // 0x124: jal x0, advance_mepc
        memory[73] = 32'h0040006f;

        // 0x128: advance_mepc: csrrs x7, mepc, x0
        memory[74] = 32'h341023f3;

        // 0x12c: addi x7, x7, 4
        memory[75] = 32'h00438393;

        // 0x130: csrrw x0, mepc, x7
        memory[76] = 32'h34139073;

        // 0x134: mret
        memory[77] = 32'h30200073;
    end

    assign instruction =
        memory[address[9:2]];

endmodule
