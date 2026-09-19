module instruction_memory (
    input  wire [31:0] address,
    output wire [31:0] instruction
);

    reg [31:0] memory [0:255];


    initial begin
        // 0x00: addi x1, x0, 0x103
        memory[0] = 32'h10300093;

        // 0x04: csrw mepc, x1
        memory[1] = 32'h34109073;

        // 0x08: csrr x2, mepc
        memory[2] = 32'h34102173;

        // 0x0c: mret
        memory[3] = 32'h30200073;

        // 0x100: addi x3, x0, 42
        memory[64] = 32'h02a00193;

        // 0x104: loop
        memory[65] = 32'h0000006f;
    end

    assign instruction =
        memory[address[9:2]];

endmodule
