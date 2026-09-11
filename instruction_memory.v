module instruction_memory (
    input  wire [31:0] address,
    output wire [31:0] instruction
);

    reg [31:0] memory [0:255];


    initial begin
        // addi x1, x0, 10
        memory[0] = 32'h00a00093;

        // xori x2, x1, 15
        memory[1] = 32'h00f0c113;

        // ori x3, x1, 5
        memory[2] = 32'h0050e193;

        // andi x4, x1, 6
        memory[3] = 32'h0060f213;

        // nop
        memory[4] = 32'h00000013;
    end

    assign instruction =
        memory[address[9:2]];

endmodule
