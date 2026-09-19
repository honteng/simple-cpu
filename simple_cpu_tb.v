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

        $display("mtvec  = %h", cpu.mtvec);
        $display("mepc   = %h", cpu.mepc);
        $display("mcause = %h", cpu.mcause);
        $display("x10    = %d", cpu.rf.registers[10]);

        if (cpu.mtvec !== 32'h00000180)
            $fatal(1, "CSRW did not update mtvec: %h", cpu.mtvec);

        if (cpu.mepc !== 32'h00000008)
            $fatal(1, "ECALL mepc should be 0x08: %h", cpu.mepc);

        if (cpu.mcause !== 32'd11)
            $fatal(1, "ECALL should set mcause to 11: %h", cpu.mcause);

        if (cpu.rf.registers[10] !== 32'd1)
            $fatal(1, "Handler at mtvec was not executed");

        $display("PASS");
        $finish;
    end

endmodule
