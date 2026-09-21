`timescale 1ns/1ps

module exception_tb;

    reg [31:0] instruction;
    reg [6:0]  opcode;
    reg [2:0]  funct3;

    reg illegal_instruction;
    reg illegal_alu_instruction;

    reg instruction_address_misaligned;
    reg [31:0] control_target;

    reg load_misaligned;
    reg store_misaligned;
    reg [31:0] memory_address;

    wire is_mret;
    wire trap;
    wire [31:0] trap_cause;
    wire [31:0] trap_value;

    trap_controller dut (
        .instruction(instruction),
        .opcode(opcode),
        .funct3(funct3),

        .illegal_instruction(illegal_instruction),
        .illegal_alu_instruction(illegal_alu_instruction),

        .instruction_address_misaligned(
            instruction_address_misaligned
        ),
        .control_target(control_target),

        .load_misaligned(load_misaligned),
        .store_misaligned(store_misaligned),
        .memory_address(memory_address),

        .is_mret(is_mret),
        .trap(trap),
        .trap_cause(trap_cause),
        .trap_value(trap_value)
    );

    task clear_inputs;
        begin
            instruction = 32'h00000013; // NOP = addi x0,x0,0
            opcode = 7'b0010011;
            funct3 = 3'b000;

            illegal_instruction = 0;
            illegal_alu_instruction = 0;

            instruction_address_misaligned = 0;
            control_target = 0;

            load_misaligned = 0;
            store_misaligned = 0;
            memory_address = 0;

            #1;
        end
    endtask

    initial begin

        // ------------------------------------------------
        // No exception
        // ------------------------------------------------
        clear_inputs();

        if (trap !== 0)
            $fatal(1, "Normal instruction caused trap");


        // ------------------------------------------------
        // Illegal instruction
        // unsupported MUL
        // ------------------------------------------------
        clear_inputs();

        instruction = 32'h023100b3;
        opcode = 7'b0110011;
        illegal_alu_instruction = 1;

        #1;

        if (!trap)
            $fatal(1, "Illegal instruction did not trap");

        if (trap_cause !== 32'd2)
            $fatal(1, "Expected mcause=2");

        if (trap_value !== 32'h023100b3)
            $fatal(1, "Illegal instruction mtval incorrect");


        // ------------------------------------------------
        // EBREAK
        // ------------------------------------------------
        clear_inputs();

        instruction = 32'h00100073;
        opcode = 7'b1110011;
        funct3 = 3'b000;

        #1;

        if (!trap || trap_cause !== 32'd3)
            $fatal(1, "EBREAK failed");


        // ------------------------------------------------
        // Load address misaligned
        // ------------------------------------------------
        clear_inputs();

        load_misaligned = 1;
        memory_address = 32'h00000102;

        #1;

        if (!trap || trap_cause !== 32'd4)
            $fatal(1, "Load misaligned failed");

        if (trap_value !== 32'h00000102)
            $fatal(1, "Load mtval incorrect");


        // ------------------------------------------------
        // Store address misaligned
        // ------------------------------------------------
        clear_inputs();

        store_misaligned = 1;
        memory_address = 32'h00000202;

        #1;

        if (!trap || trap_cause !== 32'd6)
            $fatal(1, "Store misaligned failed");

        if (trap_value !== 32'h00000202)
            $fatal(1, "Store mtval incorrect");


        // ------------------------------------------------
        // ECALL from M-mode
        // ------------------------------------------------
        clear_inputs();

        instruction = 32'h00000073;
        opcode = 7'b1110011;
        funct3 = 3'b000;

        #1;

        if (!trap || trap_cause !== 32'd11)
            $fatal(1, "ECALL failed");

        if (trap_value !== 32'd0)
            $fatal(1, "ECALL mtval should be 0");


        // ------------------------------------------------
        // Instruction address misaligned
        // ------------------------------------------------
        clear_inputs();

        instruction_address_misaligned = 1;
        control_target = 32'h00000102;

        #1;

        if (!trap || trap_cause !== 32'd0)
            $fatal(1, "Instruction-address-misaligned failed");

        if (trap_value !== 32'h00000102)
            $fatal(1, "Instruction target mtval incorrect");


        // ------------------------------------------------
        // MRET is legal and is not an exception
        // ------------------------------------------------
        clear_inputs();

        instruction = 32'h30200073;
        opcode = 7'b1110011;
        funct3 = 3'b000;

        #1;

        if (!is_mret)
            $fatal(1, "MRET not detected");

        if (trap)
            $fatal(1, "MRET incorrectly caused trap");


        $display("PASS: exception_tb");
        $finish;
    end

endmodule
