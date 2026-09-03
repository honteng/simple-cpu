module instruction_memory (
    input  wire [31:0] address,
    output wire [31:0] instruction
);

    reg [31:0] memory [0:255];


    initial begin
        // 0x00
        // jal x1, function
        // function is at 0x10; x1 receives the return address 0x04
        memory[0] = 32'h010000ef;

        // 0x04
        // addi x2, x0, 42 (runs after the function returns)
        memory[1] = 32'h02a00113;

        // 0x08
        // jal x0, done
        // Skip the function body after returning to the caller.
        memory[2] = 32'h0100006f;

        // 0x0c
        // nop
        memory[3] = 32'h00000013;

        // 0x10
        // function: addi x3, x0, 7
        memory[4] = 32'h00700193;

        // 0x14
        // jalr x0, 0(x1)
        // Return to the address saved by JAL without writing a link register.
        memory[5] = 32'h00008067;

        // 0x18
        // done: addi x4, x0, 99
        memory[6] = 32'h06300213;

        // 0x1c
        // nop
        memory[7] = 32'h00000013;
    end

    assign instruction =
        memory[address[9:2]];

endmodule
