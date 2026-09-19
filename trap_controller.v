module trap_controller (
    input wire [31:0] instruction,
    input wire [6:0]  opcode,
    input wire [2:0]  funct3,

    input wire illegal_instruction,
    input wire illegal_alu_instruction,

    input wire instruction_address_misaligned,
    input wire [31:0] control_target,

    input wire load_misaligned,
    input wire store_misaligned,
    input wire [31:0] memory_address,

    output wire is_mret,
    output wire trap,
    output wire [31:0] trap_cause,
    output wire [31:0] trap_value
);

    wire is_ecall;
    wire is_ebreak;
    wire valid_system_instruction;
    wire illegal_system_instruction;
    wire illegal_instruction_final;

    assign is_mret =
        instruction == 32'h30200073;

    assign is_ecall =
        instruction == 32'h00000073;

    assign is_ebreak =
        instruction == 32'h00100073;

    assign valid_system_instruction =
        is_ecall  ||
        is_ebreak ||
        is_mret;

    // SYSTEM instructions with funct3=000 must be one of the
    // explicitly supported privileged/system instructions.
    assign illegal_system_instruction =
        opcode == 7'b1110011 &&
        funct3 == 3'b000 &&
        !valid_system_instruction;

    assign illegal_instruction_final =
        illegal_instruction        ||
        illegal_system_instruction ||
        illegal_alu_instruction;

    assign trap =
        instruction_address_misaligned ||
        illegal_instruction_final      ||
        load_misaligned                ||
        store_misaligned               ||
        is_ecall                       ||
        is_ebreak;

    assign trap_cause =
        instruction_address_misaligned ? 32'd0  :
        illegal_instruction_final      ? 32'd2  :
        is_ebreak                      ? 32'd3  :
        load_misaligned                ? 32'd4  :
        store_misaligned               ? 32'd6  :
        is_ecall                       ? 32'd11 :
                                         32'd0;

    assign trap_value =
        instruction_address_misaligned
            ? control_target
            : illegal_instruction_final
                ? instruction
                : load_misaligned || store_misaligned
                    ? memory_address
                    : 32'd0;

endmodule
