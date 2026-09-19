module instruction_memory (
    input  wire [31:0] address,
    output wire [31:0] instruction
);

    reg [31:0] memory [0:255];


    initial begin
        // addi x1, x0, 10
        memory[0] = 32'h00a00093;

        // unsupported MUL x1, x2, x3
        memory[1] = 32'h023100b3;

        // handler @ 0x100

        // csrr x5, mcause
        memory[64] = 32'h342022f3;

        // csrr x6, mtval
        memory[65] = 32'h34302373;

        // jal x0, 0
        memory[66] = 32'h0000006f;
    end

    assign instruction =
        memory[address[9:2]];

endmodule
