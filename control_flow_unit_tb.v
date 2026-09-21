`timescale 1ns/1ps

module control_flow_unit_tb;

    reg [31:0] pc;
    reg [31:0] immediate;

    reg [31:0] read_data1;
    reg [31:0] read_data2;
    reg [31:0] alu_result;

    reg branch;
    reg jump;
    reg jump_reg;
    reg [2:0] branch_type;

    reg take_trap;
    reg [31:0] mtvec;

    reg is_mret;
    reg [31:0] mepc;

    wire [31:0] next_pc;
    wire [31:0] next_pc_no_trap;
    wire [31:0] pc_plus_4;
    wire [31:0] control_target;
    wire instruction_address_misaligned;

    localparam BR_NONE = 3'b000;
    localparam BR_EQ   = 3'b001;
    localparam BR_NE   = 3'b010;
    localparam BR_LT   = 3'b011;
    localparam BR_GE   = 3'b100;

    control_flow_unit dut (
        .pc(pc),
        .immediate(immediate),

        .read_data1(read_data1),
        .read_data2(read_data2),
        .alu_result(alu_result),

        .branch(branch),
        .jump(jump),
        .jump_reg(jump_reg),
        .branch_type(branch_type),

        .take_trap(take_trap),
        .mtvec(mtvec),

        .is_mret(is_mret),
        .mepc(mepc),

        .next_pc(next_pc),
        .next_pc_no_trap(next_pc_no_trap),
        .pc_plus_4(pc_plus_4),

        .control_target(control_target),
        .instruction_address_misaligned(
            instruction_address_misaligned
        )
    );

    task clear_inputs;
        begin
            pc = 32'h00000100;
            immediate = 0;

            read_data1 = 0;
            read_data2 = 0;
            alu_result = 0;

            branch = 0;
            jump = 0;
            jump_reg = 0;
            branch_type = BR_NONE;

            take_trap = 0;
            mtvec = 32'h00000400;

            is_mret = 0;
            mepc = 32'h00000300;

            #1;
        end
    endtask

    initial begin

        // ------------------------------------------------
        // Normal PC + 4
        // ------------------------------------------------
        clear_inputs();

        if (pc_plus_4 !== 32'h00000104)
            $fatal(1, "PC+4 failed");

        if (next_pc_no_trap !== 32'h00000104)
            $fatal(1, "Normal next PC failed");

        if (next_pc !== 32'h00000104)
            $fatal(1, "Normal final PC failed");


        // ------------------------------------------------
        // BEQ taken
        // ------------------------------------------------
        clear_inputs();

        branch = 1;
        branch_type = BR_EQ;

        read_data1 = 32'd10;
        read_data2 = 32'd10;

        immediate = 32'd16;

        #1;

        if (next_pc_no_trap !== 32'h00000110)
            $fatal(1, "BEQ taken failed");


        // ------------------------------------------------
        // BEQ not taken
        // ------------------------------------------------
        clear_inputs();

        branch = 1;
        branch_type = BR_EQ;

        read_data1 = 10;
        read_data2 = 20;

        immediate = 16;

        #1;

        if (next_pc_no_trap !== 32'h00000104)
            $fatal(1, "BEQ not-taken failed");


        // ------------------------------------------------
        // BLT signed comparison
        //
        // -1 < 1
        // ------------------------------------------------
        clear_inputs();

        branch = 1;
        branch_type = BR_LT;

        read_data1 = 32'hffffffff;
        read_data2 = 32'd1;

        immediate = 32'd8;

        #1;

        if (next_pc_no_trap !== 32'h00000108)
            $fatal(1, "BLT signed comparison failed");


        // ------------------------------------------------
        // JAL
        // ------------------------------------------------
        clear_inputs();

        jump = 1;
        immediate = 32'h20;

        #1;

        if (control_target !== 32'h00000120)
            $fatal(1, "JAL control target failed");

        if (next_pc_no_trap !== 32'h00000120)
            $fatal(1, "JAL failed");


        // ------------------------------------------------
        // JALR bit 0 clearing
        //
        // 0x105 -> 0x104
        // ------------------------------------------------
        clear_inputs();

        jump_reg = 1;
        alu_result = 32'h00000105;

        #1;

        if (control_target !== 32'h00000104)
            $fatal(1, "JALR bit-0 clearing failed");

        if (instruction_address_misaligned)
            $fatal(1, "Aligned JALR marked misaligned");


        // ------------------------------------------------
        // JALR misaligned
        //
        // 0x103 -> 0x102
        // ------------------------------------------------
        clear_inputs();

        jump_reg = 1;
        alu_result = 32'h00000103;

        #1;

        if (control_target !== 32'h00000102)
            $fatal(1, "JALR target incorrect");

        if (!instruction_address_misaligned)
            $fatal(
                1,
                "Misaligned JALR not detected"
            );


        // ------------------------------------------------
        // MRET
        // ------------------------------------------------
        clear_inputs();

        is_mret = 1;
        mepc = 32'h00000300;

        #1;

        if (next_pc_no_trap !== 32'h00000300)
            $fatal(1, "MRET failed");


        // ------------------------------------------------
        // Trap has highest priority
        // ------------------------------------------------
        clear_inputs();

        jump = 1;
        immediate = 32'h20;

        take_trap = 1;
        mtvec = 32'h00000400;

        #1;

        // Without trap, JAL wants 0x120.
        if (next_pc_no_trap !== 32'h00000120)
            $fatal(
                1,
                "next_pc_no_trap should preserve JAL target"
            );

        // But final PC must go to mtvec.
        if (next_pc !== 32'h00000400)
            $fatal(
                1,
                "Trap did not override control flow"
            );


        $display("PASS: control_flow_unit_tb");
        $finish;
    end

endmodule
