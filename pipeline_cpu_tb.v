`timescale 1ns/1ps

module pipeline_cpu_tb;

    reg clk;
    reg reset;

    pipeline_cpu cpu (
        .clk(clk),
        .reset(reset)
    );

    always #5 clk = ~clk;

    initial begin
        $dumpfile("pipeline_cpu.vcd");
        $dumpvars(0, pipeline_cpu_tb);

        clk = 0;
        reset = 1;

        // Let instruction_memory initial block run first.
        #1;

        // ------------------------------------------------
        // Simple test program
        // ------------------------------------------------

        // 0x00: addi x1, x0, 1
        cpu.imem.memory[0] = 32'h00100093;

        // 0x04: addi x2, x0, 2
        cpu.imem.memory[1] = 32'h00200113;

        // 0x08: addi x3, x0, 3
        cpu.imem.memory[2] = 32'h00300193;

        // Hold reset for a couple of clocks.
        repeat (2) @(posedge clk);

        @(negedge clk);
        reset = 0;


        // ========================================================
        // Cycle 1
        //
        // IF fetched instruction @ 0x00
        // PC advances to 0x04
        // IF/ID holds instruction @ 0x00
        // ========================================================

        @(posedge clk);
        #1;

        if (cpu.pc !== 32'h00000004)
            $fatal(
                1,
                "Cycle 1: expected PC=4, got %h",
                cpu.pc
            );

        if (cpu.if_id_pc !== 32'h00000000)
            $fatal(
                1,
                "Cycle 1: expected IF/ID PC=0"
            );

        if (cpu.if_id_pc_plus_4 !== 32'h00000004)
            $fatal(
                1,
                "Cycle 1: expected IF/ID PC+4=4"
            );

        if (cpu.if_id_instruction !== 32'h00100093)
            $fatal(
                1,
                "Cycle 1: wrong instruction"
            );

        if (!cpu.if_id_valid)
            $fatal(
                1,
                "Cycle 1: IF/ID should be valid"
            );


        // ========================================================
        // Cycle 2
        // ========================================================

        @(posedge clk);
        #1;

        if (cpu.pc !== 32'h00000008)
            $fatal(
                1,
                "Cycle 2: expected PC=8"
            );

        if (cpu.if_id_pc !== 32'h00000004)
            $fatal(
                1,
                "Cycle 2: expected IF/ID PC=4"
            );

        if (cpu.if_id_instruction !== 32'h00200113)
            $fatal(
                1,
                "Cycle 2: wrong instruction"
            );


        // ========================================================
        // Cycle 3
        // ========================================================

        @(posedge clk);
        #1;

        if (cpu.pc !== 32'h0000000c)
            $fatal(
                1,
                "Cycle 3: expected PC=0x0c"
            );

        if (cpu.if_id_pc !== 32'h00000008)
            $fatal(
                1,
                "Cycle 3: expected IF/ID PC=8"
            );

        if (cpu.if_id_instruction !== 32'h00300193)
            $fatal(
                1,
                "Cycle 3: wrong instruction"
            );


        $display("PASS: pipeline_cpu_tb");
        $finish;
    end

endmodule
