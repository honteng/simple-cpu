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

        $display("x1 = %h", cpu.rf.registers[1]);
        $display("x2 = %d", cpu.rf.registers[2]);
        $display("x3 = %d", cpu.rf.registers[3]);

        if (cpu.rf.registers[1] !== 32'hffffffff)
            $fatal(1, "ADDI should write -1 to x1");

        if (cpu.rf.registers[2] !== 32'd1)
            $fatal(1, "SLTI should treat x1 as signed");

        if (cpu.rf.registers[3] !== 32'd0)
            $fatal(1, "SLTIU should treat x1 as unsigned");

        $finish;
    end

endmodule
