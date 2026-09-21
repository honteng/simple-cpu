`timescale 1ns/1ps

module timer_interrupt_tb;

    reg clk;
    reg reset;
    reg external_irq;
    reg timer_irq;

    integer i;

    simple_cpu cpu (
        .clk(clk),
        .reset(reset),
        .external_irq(external_irq),
        .timer_irq(timer_irq)
    );

    always #5 clk = ~clk;

    initial begin

        clk = 0;
        reset = 1;

        external_irq = 0;
        timer_irq = 1;

        #1;

        for (i = 0; i < 256; i = i + 1)
            cpu.imem.memory[i] = 32'h0000006f;


        // ------------------------------------------------
        // Program
        // ------------------------------------------------

        // 0x00: addi x1, x0, 8
        cpu.imem.memory[0] = 32'h00800093;

        // 0x04: csrw mstatus, x1
        cpu.imem.memory[1] = 32'h30009073;

        // 0x08: addi x2, x0, 0x80
        // MTIE
        cpu.imem.memory[2] = 32'h08000113;

        // 0x0c: csrw mie, x2
        cpu.imem.memory[3] = 32'h30411073;

        // 0x10: addi x3, x0, 42
        cpu.imem.memory[4] = 32'h02a00193;

        // 0x14: addi x4, x0, 77
        cpu.imem.memory[5] = 32'h04d00213;


        // ------------------------------------------------
        // Handler @ 0x100
        // ------------------------------------------------

        // csrr x5, mip
        cpu.imem.memory[64] = 32'h344022f3;

        // addi x10, x0, 1
        cpu.imem.memory[65] = 32'h00100513;

        // loop
        cpu.imem.memory[66] = 32'h0000006f;


        #9;
        reset = 0;

        repeat (20) @(posedge clk);
        #1;


        if (cpu.rf.registers[3] !== 32'd42)
            $fatal(
                1,
                "Interrupted instruction did not complete"
            );

        if (cpu.rf.registers[4] !== 32'd0)
            $fatal(
                1,
                "Instruction after interrupt executed"
            );

        if (cpu.mepc !== 32'h00000014)
            $fatal(
                1,
                "Expected mepc=0x14, got %h",
                cpu.mepc
            );

        if (cpu.mcause !== 32'h80000007)
            $fatal(
                1,
                "Expected Machine Timer Interrupt"
            );

        if (cpu.mtval !== 32'd0)
            $fatal(
                1,
                "Interrupt mtval should be zero"
            );

        if (cpu.mip !== 32'h00000080)
            $fatal(
                1,
                "Expected mip.MTIP"
            );

        if (cpu.rf.registers[5] !== 32'h00000080)
            $fatal(
                1,
                "Handler did not read MTIP"
            );

        if (cpu.rf.registers[10] !== 32'd1)
            $fatal(
                1,
                "Timer handler was not executed"
            );

        if (cpu.mstatus !== 32'h00000080)
            $fatal(
                1,
                "Trap should move MIE to MPIE"
            );


        $display("PASS: timer_interrupt_tb");
        $finish;
    end

endmodule
