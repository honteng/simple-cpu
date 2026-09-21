`timescale 1ns/1ps

module external_interrupt_tb;

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

        external_irq = 1;
        timer_irq = 0;

        // Let instruction_memory's initial block finish first.
        #1;

        // Default every instruction to:
        // jal x0, 0
        for (i = 0; i < 256; i = i + 1)
            cpu.imem.memory[i] = 32'h0000006f;


        // ------------------------------------------------
        // Program
        // ------------------------------------------------

        // 0x00: addi x1, x0, 8
        // mstatus.MIE
        cpu.imem.memory[0] = 32'h00800093;

        // 0x04: csrw mstatus, x1
        cpu.imem.memory[1] = 32'h30009073;

        // Build 0x800 for MEIE.

        // 0x08: lui x2, 1
        // x2 = 0x1000
        cpu.imem.memory[2] = 32'h00001137;

        // 0x0c: addi x2, x2, -2048
        // x2 = 0x800
        cpu.imem.memory[3] = 32'h80010113;

        // 0x10: csrw mie, x2
        // MEIE = 1
        cpu.imem.memory[4] = 32'h30411073;

        // 0x14: addi x3, x0, 42
        //
        // This instruction must COMPLETE before
        // the interrupt is taken.
        cpu.imem.memory[5] = 32'h02a00193;

        // 0x18: addi x4, x0, 77
        //
        // This instruction must NOT execute yet.
        cpu.imem.memory[6] = 32'h04d00213;


        // ------------------------------------------------
        // Handler @ 0x100
        // ------------------------------------------------

        // csrr x5, mip
        cpu.imem.memory[64] = 32'h344022f3;

        // addi x10, x0, 1
        cpu.imem.memory[65] = 32'h00100513;

        // loop
        cpu.imem.memory[66] = 32'h0000006f;


        // Release reset
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

        if (cpu.mepc !== 32'h00000018)
            $fatal(
                1,
                "Expected mepc=0x18, got %h",
                cpu.mepc
            );

        if (cpu.mcause !== 32'h8000000b)
            $fatal(
                1,
                "Expected Machine External Interrupt"
            );

        if (cpu.mtval !== 32'd0)
            $fatal(
                1,
                "Interrupt mtval should be zero"
            );

        if (cpu.mip !== 32'h00000800)
            $fatal(
                1,
                "Expected mip.MEIP"
            );

        if (cpu.rf.registers[5] !== 32'h00000800)
            $fatal(
                1,
                "Handler did not read MEIP"
            );

        if (cpu.rf.registers[10] !== 32'd1)
            $fatal(
                1,
                "External interrupt handler not executed"
            );

        if (cpu.mstatus !== 32'h00000080)
            $fatal(
                1,
                "Trap should move MIE to MPIE"
            );


        $display("PASS: external_interrupt_tb");
        $finish;
    end

endmodule
