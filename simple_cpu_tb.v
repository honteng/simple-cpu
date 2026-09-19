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

        $display("mepc = %h", cpu.mepc);
        $display("x2   = %h", cpu.rf.registers[2]);
        $display("x3   = %d", cpu.rf.registers[3]);

        if (cpu.mepc !== 32'h00000100)
            $fatal(
                1,
                "mepc should be aligned to 0x100, got %h",
                cpu.mepc
            );

        if (cpu.rf.registers[2] !== 32'h00000100)
            $fatal(
                1,
                "Reading mepc should return 0x100"
            );

        if (cpu.rf.registers[3] !== 32'd42)
            $fatal(
                1,
                "MRET did not return to aligned mepc"
            );

        $display("PASS");
        $finish;
    end

endmodule
