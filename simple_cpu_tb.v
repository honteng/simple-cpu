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
        $display("x2 = %h", cpu.rf.registers[2]);
        $display("x3 = %h", cpu.rf.registers[3]);
        $display("x4 = %h", cpu.rf.registers[4]);

        if (cpu.rf.registers[1] !== 32'd100)
            $fatal(1, "ADDI address setup failed");

        if (cpu.rf.registers[2] !== 32'hffffffff)
            $fatal(1, "ADDI should write -1 to x2");

        if (cpu.dmem.memory[100] !== 8'hff)
            $fatal(1, "SB should store the low byte at address 100");

        if (cpu.rf.registers[3] !== 32'hffffffff)
            $fatal(1, "LB should sign-extend 0xff");

        if (cpu.rf.registers[4] !== 32'h000000ff)
            $fatal(1, "LBU should zero-extend 0xff");

        $finish;
    end

endmodule
