module instruction_memory (
    input  wire [31:0] address,
    output wire [31:0] instruction
);

    reg [31:0] memory [0:255];


    initial begin
        // addi x1, x0, 8
        memory[0] = 32'h00800093;

        // addi x2, x0, 2
        memory[1] = 32'h00200113;

        // sll x3, x1, x2
        memory[2] = 32'h002091b3;

        // srl x4, x1, x2
        memory[3] = 32'h0020d233;

        // nop
        memory[4] = 32'h00000013;
    end

    assign instruction =
        memory[address[9:2]];

endmodule
