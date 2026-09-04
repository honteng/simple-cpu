module instruction_memory (
    input  wire [31:0] address,
    output wire [31:0] instruction
);

    reg [31:0] memory [0:2047];


    initial begin
        // 0x0000
        // auipc x5, 0x1
        // x5 = 0x1000
        memory[0] = 32'h00001297;

        // 0x0004
        // jalr x1, 16(x5)
        // target = 0x1010; x1 = 0x0008
        memory[1] = 32'h010280e7;

        // 0x0008
        // This instruction must be skipped when JALR succeeds.
        // addi x2, x0, 99
        memory[2] = 32'h06300113;

        // 0x1010 / 4 = 1028
        // addi x6, x0, 42
        memory[1028] = 32'h02a00313;

        // 0x1014
        // nop
        memory[1029] = 32'h00000013;
    end

    assign instruction =
        memory[address[12:2]];

endmodule
