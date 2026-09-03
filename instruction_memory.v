module instruction_memory (
    input  wire [31:0] address,
    output wire [31:0] instruction
);

    reg [31:0] memory [0:255];


    initial begin
        // 0x00
        // jal x5, 16
        // target = 0x10; x5 receives the return address 0x04
        memory[0] = 32'h010002ef;

        // 0x04
        // addi x2, x0, 99 (skipped by JAL)
        memory[1] = 32'h06300113;

        // 0x08
        // addi x3, x0, 77 (skipped by JAL)
        memory[2] = 32'h04d00193;

        // 0x0c
        // addi x4, x0, 66 (skipped by JAL)
        memory[3] = 32'h04200213;

        // 0x10
        // addi x1, x0, 33
        memory[4] = 32'h02100093;

        // 0x14
        // jalr x6, 0(x1)
        // target = (33 + 0) & ~1 = 32 (0x20); x6 receives 0x18
        memory[5] = 32'h00008367;

        // 0x18
        // addi x2, x0, 55 (skipped by JALR)
        memory[6] = 32'h03700113;

        // 0x1c
        // addi x3, x0, 66 (skipped by JALR)
        memory[7] = 32'h04200193;

        // 0x20
        // addi x4, x0, 42
        memory[8] = 32'h02a00213;

        // 0x24
        // nop
        memory[9] = 32'h00000013;
    end

    assign instruction =
        memory[address[9:2]];

endmodule
