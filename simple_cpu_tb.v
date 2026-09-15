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

        #120;

        $display("mepc   = %h", cpu.mepc);
        $display("mcause = %h", cpu.mcause);
        $display("x1     = %d", cpu.rf.registers[1]);
        $display("x2     = %d", cpu.rf.registers[2]);
        $display("x5     = %h", cpu.rf.registers[5]);

        if (cpu.mcause !== 32'd11)
            $fatal(1, "ECALL should set mcause to 11: %h", cpu.mcause);

        if (cpu.mepc !== 32'h00000008)
            $fatal(1, "Handler should advance mepc to 0x08: %h", cpu.mepc);

        if (cpu.rf.registers[1] !== 32'd10)
            $fatal(1, "Instruction before ECALL did not execute");

        if (cpu.rf.registers[2] !== 32'd42)
            $fatal(1, "Execution did not resume after ECALL");

        if (cpu.rf.registers[5] !== 32'h00000008)
            $fatal(1, "Handler did not calculate mepc + 4");

        $display("PASS");
        $finish;
    end

endmodule
