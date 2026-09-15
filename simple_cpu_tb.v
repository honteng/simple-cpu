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

        #300;

        $display("mepc   = %h", cpu.mepc);
        $display("mcause = %h", cpu.mcause);
        $display("x1     = %d", cpu.rf.registers[1]);
        $display("x2     = %d", cpu.rf.registers[2]);
        $display("x3     = %d", cpu.rf.registers[3]);
        $display("x10    = %d", cpu.rf.registers[10]);
        $display("x11    = %d", cpu.rf.registers[11]);

        if (cpu.mcause !== 32'd3)
            $fatal(1, "EBREAK should set mcause to 3: %h", cpu.mcause);

        if (cpu.mepc !== 32'h00000010)
            $fatal(1, "Second handler should advance mepc to 0x10: %h", cpu.mepc);

        if (cpu.rf.registers[1] !== 32'd10)
            $fatal(1, "Instruction before ECALL did not execute");

        if (cpu.rf.registers[2] !== 32'd42)
            $fatal(1, "Execution did not resume after ECALL");

        if (cpu.rf.registers[3] !== 32'd77)
            $fatal(1, "Execution did not resume after EBREAK");

        if (cpu.rf.registers[5] !== 32'd3 || cpu.rf.registers[7] !== 32'h00000010)
            $fatal(1, "Handler did not read mcause or calculate mepc + 4");

        if (cpu.rf.registers[10] !== 32'd1)
            $fatal(1, "ECALL handler path was not executed");

        if (cpu.rf.registers[11] !== 32'd1)
            $fatal(1, "EBREAK handler path was not executed");

        $display("PASS");
        $finish;
    end

endmodule
