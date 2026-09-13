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
        // A rejected load must preserve an existing destination value.
        cpu.rf.registers[4] = 32'h12345678;
        reset = 0;

        #40;
        if (cpu.pc !== 32'd16 || cpu.alu_result !== 32'd102)
            $fatal(1, "Misaligned load was not reached");
        if (cpu.mem_misaligned !== 1'b1 || cpu.effective_reg_write !== 1'b0)
            $fatal(1, "Misaligned load write-back was not blocked");

        #10;
        if (cpu.mepc !== 32'h00000010)
            $fatal(1, "mepc incorrect: %h", cpu.mepc);
        if (cpu.mcause !== 32'd4)
            $fatal(1, "mcause incorrect: %d", cpu.mcause);

        // Simulate a handler selecting a new return address.
        cpu.mepc = 32'h00000020;
        #1;
        if (cpu.pc !== 32'h00000100 || cpu.is_mret !== 1'b1 ||
            cpu.next_pc !== 32'h00000020)
            $fatal(1, "MRET did not select mepc as its return address");

        #19;

        $display("x1 = %d", cpu.rf.registers[1]);
        $display("x2 = %h", cpu.rf.registers[2]);
        $display("x3 = %h", cpu.rf.registers[3]);
        $display("x4 = %h", cpu.rf.registers[4]);
        $display("x5 = %d", cpu.rf.registers[5]);

        if (cpu.rf.registers[1] !== 32'd100)
            $fatal(1, "ADDI address setup failed");

        if (cpu.rf.registers[2] !== 32'd42)
            $fatal(1, "ADDI should write 42 to x2");

        if (cpu.dmem.memory[100] !== 8'h2a ||
            cpu.dmem.memory[101] !== 8'h00 ||
            cpu.dmem.memory[102] !== 8'h00 ||
            cpu.dmem.memory[103] !== 8'h00)
            $fatal(1, "Aligned SW failed or byte order is incorrect");

        if (cpu.rf.registers[3] !== 32'd42)
            $fatal(1, "Aligned LW failed");

        if (cpu.rf.registers[4] !== 32'h12345678)
            $fatal(1, "Misaligned LW changed its destination register");

        if (cpu.mepc !== 32'h00000020)
            $fatal(1, "mepc incorrect: %h", cpu.mepc);

        if (cpu.mcause !== 32'd4)
            $fatal(1, "mcause incorrect: %d", cpu.mcause);

        if (cpu.rf.registers[5] !== 32'd42)
            $fatal(1, "MRET return target was not executed");

        $finish;
    end

endmodule
