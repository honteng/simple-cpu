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

        #60;

        $display("x1 = %d", cpu.rf.registers[1]);
        $display("x2 = %d", cpu.rf.registers[2]);
        $display("x3 = %d", cpu.rf.registers[3]);
        $display("x4 = %d", cpu.rf.registers[4]);
        $display("x5 = %d", cpu.rf.registers[5]);
        $display("x6 = %d", cpu.rf.registers[6]);

        if (cpu.rf.registers[1] !== 32'd33) $fatal(1, "x1 mismatch");
        if (cpu.rf.registers[2] !== 32'd0)  $fatal(1, "x2 should be skipped by both jumps");
        if (cpu.rf.registers[3] !== 32'd0)  $fatal(1, "x3 should be skipped by both jumps");
        if (cpu.rf.registers[4] !== 32'd42) $fatal(1, "x4 target instruction mismatch");
        if (cpu.rf.registers[5] !== 32'd4)  $fatal(1, "JAL should write PC + 4 to x5");
        if (cpu.rf.registers[6] !== 32'd24) $fatal(1, "JALR should write PC + 4 to x6");

        $finish;
    end

endmodule
