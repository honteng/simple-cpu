module instruction_memory (
    input  wire [31:0] address,
    output wire [31:0] instruction
);

    reg [31:0] memory [0:255];


    initial begin
        // addi x1, x0, -1
        memory[0] = 32'hfff00093;

        // slti x2, x1, 1
        memory[1] = 32'h0010a113;

        // sltiu x3, x1, 1
        memory[2] = 32'h0010b193;

        // nop
        memory[3] = 32'h00000013;
    end

    assign instruction =
        memory[address[9:2]];

endmodule
