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

        $display("mstatus = %h", cpu.mstatus);
        $display("x2      = %h", cpu.rf.registers[2]);
        $display("x3      = %d", cpu.rf.registers[3]);

        if (cpu.rf.registers[2] !== 32'h00000080)
            $fatal(
                1,
                "Handler should observe mstatus=0x80, got %h",
                cpu.rf.registers[2]
            );

        if (cpu.mstatus !== 32'h00000088)
            $fatal(
                1,
                "MRET should restore mstatus to 0x88, got %h",
                cpu.mstatus
            );

        if (cpu.rf.registers[3] !== 32'd42)
            $fatal(
                1,
                "Execution did not resume after MRET"
            );

        $display("PASS");
        $finish;
    end

endmodule
