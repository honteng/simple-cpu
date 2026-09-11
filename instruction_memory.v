module instruction_memory (
    input  wire [31:0] address,
    output wire [31:0] instruction
);

    reg [31:0] memory [0:255];


    initial begin
        // addi x1, x0, 8
        memory[0] = 32'h00800093;

        // slli x2, x1, 2
        // 8 << 2 = 32
        memory[1] = 32'h00209113;

        // srli x3, x1, 2
        // 8 >> 2 = 2
        memory[2] = 32'h0020d193;

        // addi x4, x0, -16
        memory[3] = 32'hff000213;

        // srai x5, x4, 2
        // -16 >>> 2 = -4
        memory[4] = 32'h40225293;

        // srli x6, x4, 2
        // 0xfffffff0 >> 2 = 0x3ffffffc
        memory[5] = 32'h00225313;

        // nop
        memory[6] = 32'h00000013;
    end

    assign instruction =
        memory[address[9:2]];

endmodule
