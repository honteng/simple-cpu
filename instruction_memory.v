module instruction_memory (
    input  wire [31:0] address,
    output wire [31:0] instruction
);

    reg [31:0] memory [0:255];


    initial begin
        // 0x00: addi x1, x0, 8
        memory[0] = 32'h00800093;

        // 0x04: csrw mstatus, x1
        memory[1] = 32'h30009073;

        // 0x08: ecall
        memory[2] = 32'h00000073;

        // 0x0c: addi x3, x0, 42
        memory[3] = 32'h02a00193;

        // 0x10: loop
        memory[4] = 32'h0000006f;

        // Trap handler @ 0x100

        // csrr x2, mstatus
        memory[64] = 32'h30002173;

        // csrr x4, mepc
        memory[65] = 32'h34102273;

        // addi x4, x4, 4
        memory[66] = 32'h00420213;

        // csrw mepc, x4
        memory[67] = 32'h34121073;

        // mret
        memory[68] = 32'h30200073;
    end

    assign instruction =
        memory[address[9:2]];

endmodule
