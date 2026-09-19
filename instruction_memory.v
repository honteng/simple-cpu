module instruction_memory (
    input  wire [31:0] address,
    output wire [31:0] instruction
);

    reg [31:0] memory [0:255];


    initial begin
        // addi x1, x0, 0x180
        memory[0] = 32'h18000093;

        // csrw mtvec, x1
        memory[1] = 32'h30509073;

        // ecall
        memory[2] = 32'h00000073;

        // handler @ 0x180

        // addi x10, x0, 1
        memory[96] = 32'h00100513;

        // jal x0, 0
        memory[97] = 32'h0000006f;
    end

    assign instruction =
        memory[address[9:2]];

endmodule
