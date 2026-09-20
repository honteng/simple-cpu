`timescale 1ns/1ps

module simple_cpu_tb;

    reg clk;
    reg reset;
    reg external_irq;

    simple_cpu cpu (
        .clk(clk),
        .reset(reset),
        .external_irq(external_irq)
    );

    always #5 clk = ~clk;

    initial begin
        $dumpfile("simple_cpu.vcd");
        $dumpvars(0, simple_cpu_tb);

        clk = 0;
        reset = 1;
        external_irq = 0;

        #6;
        reset = 0;

        // Assert the interrupt while the instruction at 0x14 executes.
        wait (cpu.pc == 32'h00000014);
        #1;
        external_irq = 1;

        #10;
        external_irq = 0;

        #60;

        $display("mstatus = %h", cpu.mstatus);
        $display("mie     = %h", cpu.mie);
        $display("mepc    = %h", cpu.mepc);
        $display("mcause  = %h", cpu.mcause);
        $display("mtval   = %h", cpu.mtval);
        $display("x3      = %d", cpu.rf.registers[3]);
        $display("x4      = %d", cpu.rf.registers[4]);

        if (cpu.rf.registers[3] !== 32'd42)
            $fatal(
                1,
                "Interrupted instruction did not complete"
            );

        if (cpu.rf.registers[4] !== 32'd0)
            $fatal(1, "Instruction after interrupt was executed");

        if (cpu.mepc !== 32'h00000018)
            $fatal(1, "Expected mepc=0x18, got %h", cpu.mepc);

        if (cpu.mcause !== 32'h8000000b)
            $fatal(
                1,
                "Expected machine external interrupt, got %h",
                cpu.mcause
            );

        if (cpu.mtval !== 32'd0)
            $fatal(1, "Interrupt mtval should be zero");

        if (cpu.mstatus !== 32'h00000080)
            $fatal(1, "Trap should set MPIE=1 and MIE=0");

        if (cpu.rf.registers[10] !== 32'd1)
            $fatal(1, "Interrupt handler was not executed");

        $display("PASS");
        $finish;
    end

endmodule
