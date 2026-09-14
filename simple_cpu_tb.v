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
        $display("x2     = %d", cpu.rf.registers[2]);
        $display("x4     = %d", cpu.rf.registers[4]);
        $display("x6     = %d", cpu.rf.registers[6]);

        if (cpu.mcause !== 32'd5)
            $fatal(1, "CSR commands should leave mcause = 5: %h", cpu.mcause);

        if (cpu.mepc !== 32'd0)
            $fatal(1, "mcause operations should not change mepc");

        if (cpu.rf.registers[1] !== 32'd3 ||
            cpu.rf.registers[3] !== 32'd4 ||
            cpu.rf.registers[5] !== 32'd2)
            $fatal(1, "ADDI source setup failed");

        if (cpu.rf.registers[2] !== 32'd0)
            $fatal(1, "CSRRW should return the old mcause = 0");

        if (cpu.rf.registers[4] !== 32'd3)
            $fatal(1, "CSRRS should return the old mcause = 3");

        if (cpu.rf.registers[6] !== 32'd7)
            $fatal(1, "CSRRC should return the old mcause = 7");

        $display("PASS");
        $finish;
    end

endmodule
