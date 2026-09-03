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

        if (cpu.rf.registers[1] !== 32'd4)  $fatal(1, "JAL should save return address 0x04 in x1");
        if (cpu.rf.registers[2] !== 32'd42) $fatal(1, "caller instruction after return did not run");
        if (cpu.rf.registers[3] !== 32'd7)  $fatal(1, "function body did not run");
        if (cpu.rf.registers[4] !== 32'd99) $fatal(1, "post-call jump did not reach done");

        $finish;
    end

endmodule
