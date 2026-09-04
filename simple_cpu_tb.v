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
        $display("x2 = %h", cpu.rf.registers[2]);
        $display("x5 = %h", cpu.rf.registers[5]);
        $display("x6 = %h", cpu.rf.registers[6]);

        if (cpu.rf.registers[1] !== 32'h00000008)
            $fatal(1, "JALR return address failed");

        if (cpu.rf.registers[2] !== 32'd0)
            $fatal(1, "Skipped instruction was executed");

        if (cpu.rf.registers[5] !== 32'h00001000)
            $fatal(1, "AUIPC failed");

        if (cpu.rf.registers[6] !== 32'd42)
            $fatal(1, "Far jump target failed");

        $finish;
    end

endmodule
