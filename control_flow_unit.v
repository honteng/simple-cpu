module control_flow_unit (
    input wire [31:0] pc,
    input wire [31:0] immediate,

    input wire [31:0] read_data1,
    input wire [31:0] read_data2,
    input wire [31:0] alu_result,

    input wire branch,
    input wire jump,
    input wire jump_reg,
    input wire [2:0] branch_type,

    input wire take_trap,
    input wire [31:0] mtvec,

    input wire is_mret,
    input wire [31:0] mepc,

    output wire [31:0] next_pc,
    output wire [31:0] next_pc_no_trap,
    output wire [31:0] pc_plus_4,

    output wire [31:0] control_target,
    output wire instruction_address_misaligned
);

    localparam BR_NONE = 3'b000;
    localparam BR_EQ   = 3'b001;
    localparam BR_NE   = 3'b010;
    localparam BR_LT   = 3'b011;
    localparam BR_GE   = 3'b100;

    reg branch_condition;

    wire branch_taken;
    wire [31:0] branch_target;
    wire [31:0] jump_target;
    wire [31:0] jalr_target;

    always @(*) begin
        case (branch_type)
            BR_EQ:
                branch_condition =
                    read_data1 == read_data2;

            BR_NE:
                branch_condition =
                    read_data1 != read_data2;

            BR_LT:
                branch_condition =
                    $signed(read_data1) <
                    $signed(read_data2);

            BR_GE:
                branch_condition =
                    $signed(read_data1) >=
                    $signed(read_data2);

            default:
                branch_condition = 0;
        endcase
    end

    assign branch_taken =
        branch && branch_condition;

    assign pc_plus_4 =
        pc + 32'd4;

    assign branch_target =
        pc + immediate;

    assign jump_target =
        pc + immediate;

    assign jalr_target =
        {alu_result[31:1], 1'b0};

    assign control_target =
        jump
            ? jump_target
            : jump_reg
                ? jalr_target
                : branch_taken
                    ? branch_target
                    : 32'd0;

    assign instruction_address_misaligned =
        (jump || jump_reg || branch_taken)
        && control_target[1:0] != 2'b00;

    assign next_pc_no_trap =
        is_mret
            ? mepc
            : jump
                ? jump_target
                : jump_reg
                    ? jalr_target
                    : branch_taken
                        ? branch_target
                        : pc_plus_4;

    assign next_pc =
        take_trap
            ? mtvec
            : next_pc_no_trap;

endmodule
