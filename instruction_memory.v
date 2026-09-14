module instruction_memory (
    input  wire [31:0] address,
    output wire [31:0] instruction
);

    reg [31:0] memory [0:255];


    initial begin
        // addi x1, x0, 3
        memory[0] = 32'h00300093;

        // csrrw x2, mcause, x1
        memory[1] = 32'h34209173;

        // addi x3, x0, 4
        memory[2] = 32'h00400193;

        // csrrs x4, mcause, x3
        memory[3] = 32'h3421a273;

        // addi x5, x0, 2
        memory[4] = 32'h00200293;

        // csrrc x6, mcause, x5
        memory[5] = 32'h3422b373;

        // jal x0, 0: stop advancing after the test sequence
        memory[6] = 32'h0000006f;
    end

    assign instruction =
        memory[address[9:2]];

endmodule
