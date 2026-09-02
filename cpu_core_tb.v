`timescale 1ns/1ps

module cpu_core_tb;

    reg clk;
    reg reset;

    cpu_core cpu (
        .clk(clk),
        .reset(reset)
    );

    always #5 clk = ~clk;

    initial begin
        $dumpfile("cpu_core.vcd");
        $dumpvars(0, cpu_core_tb);

        clk = 0;
        reset = 0;

        // x1 = 10 を直接セット
        cpu.rf.registers[1] = 32'd10;

        // x2 = 20 を直接セット
        cpu.rf.registers[2] = 32'd20;

        // add x3, x1, x2
        cpu.instruction = 32'h002081b3;

        #1;

        $display("rs1 value = %d", cpu.read_data1);
        $display("rs2 value = %d", cpu.read_data2);
        $display("alu       = %d", cpu.alu_result);

        // 5nsのposedgeで x3 に書かれる
        #5;

        #1;

        $display("x3        = %d", cpu.rf.registers[3]);

        $finish;
    end

endmodule