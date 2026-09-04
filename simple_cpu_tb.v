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

        #200;

        $display("x1 = %d", cpu.rf.registers[1]);
        $display("x2 = %d", cpu.rf.registers[2]);

        if (cpu.rf.registers[1] !== 32'd0)
            $fatal(1, "Loop counter did not reach zero");

        if (cpu.rf.registers[2] !== 32'd5)
            $fatal(1, "BNE loop should increment x2 five times");

        $finish;
    end

endmodule
