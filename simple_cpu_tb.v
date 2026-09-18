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
        $display("x5     = %d", cpu.rf.registers[5]);
        $display("x6     = %h", cpu.rf.registers[6]);

        if (cpu.mcause !== 32'd2)
            $fatal(1, "Illegal instruction should set mcause to 2: %h", cpu.mcause);

        if (cpu.mepc !== 32'h00000008)
            $fatal(1, "Handler should advance mepc to 0x08: %h", cpu.mepc);

        if (cpu.rf.registers[1] !== 32'd10)
            $fatal(1, "Instruction before ECALL did not execute");

        if (cpu.rf.registers[2] !== 32'd42)
            $fatal(1, "Execution did not resume after illegal instruction");

        if (cpu.rf.registers[5] !== 32'd2)
            $fatal(1, "Handler did not read illegal-instruction mcause");

        if (cpu.rf.registers[6] !== 32'h00000008)
            $fatal(1, "Handler did not calculate mepc + 4");

        $display("PASS");
        $finish;
    end

endmodule
