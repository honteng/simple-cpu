module instruction_memory (
    input  wire [31:0] address,
    output wire [31:0] instruction
);

    reg [31:0] memory [0:255];


    initial begin
        // addi x1, x0, 100
        memory[0] = 32'h06400093;

        // addi x2, x0, -1
        memory[1] = 32'hfff00113;

        // sb x2, 0(x1)
        memory[2] = 32'h00208023;

        // lb x3, 0(x1)
        memory[3] = 32'h00008183;

        // lbu x4, 0(x1)
        memory[4] = 32'h0000c203;

        // nop
        memory[5] = 32'h00000013;
    end

    assign instruction =
        memory[address[9:2]];

endmodule
