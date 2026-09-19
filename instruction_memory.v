module instruction_memory (
    input  wire [31:0] address,
    output wire [31:0] instruction
);

    reg [31:0] memory [0:255];


    initial begin
        // addi x1, x0, 0x103
        memory[0] = 32'h10300093;

        // jalr x5, 0(x1)
        memory[1] = 32'h000082e7;

        // handler @ 0x100

        // csrr x6, mcause
        memory[64] = 32'h34202373;

        // csrr x7, mtval
        memory[65] = 32'h343023f3;

        // jal x0, 0
        memory[66] = 32'h0000006f;
    end

    assign instruction =
        memory[address[9:2]];

endmodule
