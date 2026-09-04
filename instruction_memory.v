module instruction_memory (
    input  wire [31:0] address,
    output wire [31:0] instruction
);

    reg [31:0] memory [0:255];


    initial begin
        // addi x1, x0, 5
        memory[0] = 32'h00500093;

        // addi x2, x0, 0
        memory[1] = 32'h00000113;

        // loop: addi x2, x2, 1
        memory[2] = 32'h00110113;

        // addi x1, x1, -1
        memory[3] = 32'hfff08093;

        // bne x1, x0, loop
        // PC = 16 returns to PC = 8, so offset = -8.
        memory[4] = 32'hfe009ce3;

        // nop
        memory[5] = 32'h00000013;
    end

    assign instruction =
        memory[address[9:2]];

endmodule
