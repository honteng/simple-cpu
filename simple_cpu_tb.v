`timescale 1ns/1ps

module simple_cpu_tb;

    reg clk;
    reg reset;

    simple_cpu cpu (
        .clk(clk),
        .reset(reset)
    );

    always #5 clk = ~clk;

    initial begin
        $dumpfile("simple_cpu.vcd");
        $dumpvars(0, simple_cpu_tb);

        clk = 0;
        reset = 1;

        #6;
        reset = 0;

        #40;

        $display("x1 = %d", cpu.rf.registers[1]);
        $display("x2 = %d", cpu.rf.registers[2]);
        $display("x3 = %d", cpu.rf.registers[3]);
        $display("x4 = %d", cpu.rf.registers[4]);

        if (cpu.rf.registers[1] !== 32'd8)
            $fatal(1, "ADDI should write 8 to x1");

        if (cpu.rf.registers[2] !== 32'd2)
            $fatal(1, "ADDI should write 2 to x2");

        if (cpu.rf.registers[3] !== 32'd32)
            $fatal(1, "SLL should calculate 8 << 2");

        if (cpu.rf.registers[4] !== 32'd2)
            $fatal(1, "SRL should calculate 8 >> 2");

        $finish;
    end

endmodule
