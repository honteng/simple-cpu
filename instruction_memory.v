module instruction_memory (
    input  wire [31:0] address,
    output wire [31:0] instruction
);

    reg [31:0] memory [0:255];


    initial begin
        // 0x00
        // addi x1, x0, 17
        memory[0] = 32'h01100093;

        // 0x04
        // jalr x5, 0(x1)
        // target = (17 + 0) & ~1 = 16 (0x10)
        memory[1] = 32'h000082e7;

        // 0x08
        // addi x2, x0, 99
        // skipped
        memory[2] = 32'h06300113;

        // 0x0c
        // addi x3, x0, 77
        // skipped
        memory[3] = 32'h04d00193;

        // 0x10
        // addi x4, x0, 42
        memory[4] = 32'h02a00213;

        // 0x14
        // nop
        memory[5] = 32'h00000013;
    end

    assign instruction =
        memory[address[9:2]];

endmodule
