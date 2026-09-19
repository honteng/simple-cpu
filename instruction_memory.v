module instruction_memory (
    input  wire [31:0] address,
    output wire [31:0] instruction
);

    reg [31:0] memory [0:255];


    initial begin
        // 0x00: addi x1, x0, 10
        memory[0] = 32'h00a00093;

        // 0x04: unsupported R-type instruction (MUL x1, x2, x3)
        // RV32M is not implemented, so funct7=0000001 is illegal.
        memory[1] = 32'h023100b3;

        // 0x08: executed after returning from the handler
        // addi x2, x0, 42
        memory[2] = 32'h02a00113;

        // stop
        memory[3] = 32'h0000006f;

        // 0x100: csrr x5, mcause
        memory[64] = 32'h342022f3;

        // 0x104: csrr x6, mepc
        memory[65] = 32'h34102373;

        // 0x108: addi x6, x6, 4
        memory[66] = 32'h00430313;

        // 0x10c: csrw mepc, x6
        memory[67] = 32'h34131073;

        // 0x110: mret
        memory[68] = 32'h30200073;
    end

    assign instruction =
        memory[address[9:2]];

endmodule
