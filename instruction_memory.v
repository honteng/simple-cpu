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
        // jal x5, +8
        memory[1] = 32'h008002ef;

        // 0x08
        // addi x2, x0, 99
        // skip
        memory[2] = 32'h06300113;

        // 0x0c
        // addi x3, x0, 42
        memory[3] = 32'h02a00193;

        memory[4] = 32'h00000013;
    end

    assign instruction =
        memory[address[9:2]];

endmodule