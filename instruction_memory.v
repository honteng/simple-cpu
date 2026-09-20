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

        // 0x08: addi x2, x0, 0x80
        memory[2] = 32'h08000113;

        // 0x0c: csrw mie, x2
        memory[3] = 32'h30411073;

        // 0x10: addi x3, x0, 42
        memory[4] = 32'h02a00193;

        // 0x14: addi x4, x0, 77
        memory[5] = 32'h04d00213;

        // 0x18: loop
        memory[6] = 32'h0000006f;

        // Interrupt handler @ 0x100

        // csrr x5, mip
        memory[64] = 32'h344022f3;

        // addi x10, x0, 1
        memory[65] = 32'h00100513;

        // loop
        memory[66] = 32'h0000006f;
    end

    assign instruction =
        memory[address[9:2]];

endmodule
