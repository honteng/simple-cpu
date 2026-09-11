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

        #50;

        $display("x1 = %d", cpu.rf.registers[1]);
        $display("x2 = %d", cpu.rf.registers[2]);
        $display("x3 = %d", cpu.rf.registers[3]);
        $display("x4 = %d", cpu.rf.registers[4]);

        if (cpu.rf.registers[1] !== 32'd10)
            $fatal(1, "ADDI failed");

        if (cpu.rf.registers[2] !== 32'd5)
            $fatal(1, "XORI failed");

        if (cpu.rf.registers[3] !== 32'd15)
            $fatal(1, "ORI failed");

        if (cpu.rf.registers[4] !== 32'd2)
            $fatal(1, "ANDI failed");

        $finish;
    end

endmodule
