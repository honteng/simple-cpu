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
        $display("x4     = %d", cpu.rf.registers[4]);
        $display("x5     = %h", cpu.rf.registers[5]);

        if (cpu.mcause !== 32'd4)
            $fatal(
                1,
                "mcause should be load-address-misaligned: %d",
                cpu.mcause
            );

        if (cpu.mepc !== 32'h00000010)
            $fatal(
                1,
                "handler should update mepc to 0x10: %h",
                cpu.mepc
            );

        if (cpu.rf.registers[4] !== 32'd77)
            $fatal(
                1,
                "execution did not resume after trap"
            );

        if (cpu.rf.registers[5] !== 32'h00000010)
            $fatal(
                1,
                "handler did not calculate mepc + 4"
            );

        $display("PASS");
        $finish;
    end

endmodule
