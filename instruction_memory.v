module instruction_memory (
    input  wire [31:0] address,
    output wire [31:0] instruction
);

    reg [31:0] memory [0:255];

    initial begin

        // 0x00
        // addi x1, x0, 10
        memory[0] = 32'h00a00093;

        // 0x04
        // addi x2, x0, 10
        memory[1] = 32'h00a00113;

        // 0x08
        // beq x1, x2, +8
        //
        // PC=8 から PC=16 に飛ぶ
        memory[2] = 32'h00208463;

        // 0x0c
        // addi x3, x0, 99
        // branch成功ならskip
        memory[3] = 32'h06300193;

        // 0x10
        // addi x3, x0, 42
        memory[4] = 32'h02a00193;

        // nop
        memory[5] = 32'h00000013;
    end

    assign instruction =
        memory[address[9:2]];

endmodule