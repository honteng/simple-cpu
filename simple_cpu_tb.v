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

        $display("mcause = %h", cpu.mcause);
        $display("mtval  = %h", cpu.mtval);
        $display("x5     = %h", cpu.rf.registers[5]);
        $display("x6     = %h", cpu.rf.registers[6]);

        if (cpu.mcause !== 32'd2)
            $fatal(1, "Expected illegal instruction");

        if (cpu.mtval !== 32'h023100b3)
            $fatal(
                1,
                "Expected mtval=023100b3, got %h",
                cpu.mtval
            );

        if (cpu.rf.registers[5] !== 32'd2)
            $fatal(1, "Handler did not read mcause correctly");

        if (cpu.rf.registers[6] !== 32'h023100b3)
            $fatal(
                1,
                "Handler did not read mtval correctly"
            );

        $display("PASS");
        $finish;
    end

endmodule
