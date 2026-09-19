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
        $display("mtval  = %h", cpu.mtval);
        $display("x5     = %h", cpu.rf.registers[5]);
        $display("x7     = %h", cpu.rf.registers[7]);

        if (cpu.mepc !== 32'h00000004)
            $fatal(1, "Expected mepc=00000004, got %h", cpu.mepc);

        if (cpu.mcause !== 32'd0)
            $fatal(1, "Expected instruction-address-misaligned exception");

        if (cpu.mtval !== 32'h00000102)
            $fatal(
                1,
                "Expected mtval=00000102, got %h",
                cpu.mtval
            );

        if (cpu.rf.registers[5] !== 32'd0)
            $fatal(1, "Misaligned JALR wrote its link register");

        if (cpu.rf.registers[7] !== 32'h00000102)
            $fatal(
                1,
                "Handler did not read mtval correctly"
            );

        $display("PASS");
        $finish;
    end

endmodule
