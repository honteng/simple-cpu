module simple_cpu (
    input wire clk,
    input wire reset
);

    wire [31:0] pc;
    wire [31:0] next_pc;
    wire [31:0] instruction;

    wire [6:0] opcode;
    wire [4:0] rd;
    wire [4:0] rs1;
    wire [4:0] rs2;
    wire [2:0] funct3;
    wire [6:0] funct7;

    wire [31:0] imm_i;
    wire [31:0] imm_s;
    wire [31:0] imm_b;
    wire [31:0] imm_u;
    wire [31:0] imm_j;
    reg [31:0] immediate;

    wire [31:0] read_data1;
    wire [31:0] read_data2;

    wire [31:0] alu_input_b;
    wire [31:0] alu_result;
    wire [2:0] alu_op;

    wire [31:0] memory_read_data;
    reg [31:0] write_back_data;
    wire [31:0] auipc_result;
    wire [31:0] jump_target;
    wire [31:0] jalr_target;

    wire reg_write;
    wire mem_write;
    wire alu_src_imm;
    wire [2:0] imm_sel;
    wire [2:0] wb_sel;
    wire branch;
    wire jump;
    wire jump_reg;
    wire [2:0] branch_type;

    wire registers_equal;
    reg branch_condition;
    wire branch_taken;

    wire [31:0] pc_plus_4;
    wire [31:0] branch_target;

    localparam BR_NONE = 3'b000;
    localparam BR_EQ   = 3'b001;
    localparam BR_NE   = 3'b010;
    localparam BR_LT   = 3'b011;
    localparam BR_GE   = 3'b100;

    localparam WB_ALU   = 3'b000;
    localparam WB_MEM   = 3'b001;
    localparam WB_PC4   = 3'b010;
    localparam WB_IMM_U = 3'b011;
    localparam WB_AUIPC = 3'b100;

    localparam IMM_I = 3'b000;
    localparam IMM_S = 3'b001;
    localparam IMM_B = 3'b010;
    localparam IMM_U = 3'b011;
    localparam IMM_J = 3'b100;

    program_counter pc0 (
        .clk(clk),
        .reset(reset),
        .next_pc(next_pc),
        .pc(pc)
    );

    instruction_memory imem (
        .address(pc),
        .instruction(instruction)
    );

    instruction_decoder decoder (
        .instruction(instruction),
        .opcode(opcode),
        .rd(rd),
        .rs1(rs1),
        .rs2(rs2),
        .funct3(funct3),
        .funct7(funct7),
        .imm_i(imm_i),
        .imm_s(imm_s),
        .imm_b(imm_b),
        .imm_u(imm_u),
        .imm_j(imm_j)
    );

    control_unit control (
        .opcode(opcode),
        .funct3(funct3),
        .reg_write(reg_write),
        .mem_write(mem_write),
        .alu_src_imm(alu_src_imm),
        .imm_sel(imm_sel),
        .wb_sel(wb_sel),
        .branch(branch),
        .jump(jump),
        .jump_reg(jump_reg),
        .branch_type(branch_type)
    );

    register_file rf (
        .clk(clk),
        .write_enable(reg_write),
        .read_addr1(rs1),
        .read_addr2(rs2),
        .write_addr(rd),
        .write_data(write_back_data),
        .read_data1(read_data1),
        .read_data2(read_data2)
    );

    assign alu_input_b =
        alu_src_imm
            ? immediate
            : read_data2;

    alu_control alu_ctl (
        .opcode(opcode),
        .funct3(funct3),
        .funct7(funct7),
        .alu_op(alu_op)
    );

    alu alu0 (
        .a(read_data1),
        .b(alu_input_b),
        .op(alu_op),
        .result(alu_result)
    );

    data_memory dmem (
        .clk(clk),
        .mem_write(mem_write),
        .address(alu_result),
        .write_data(read_data2),
        .read_data(memory_read_data)
    );

    always @(*) begin
        case (imm_sel)
            IMM_S:   immediate = imm_s;
            IMM_B:   immediate = imm_b;
            IMM_U:   immediate = imm_u;
            IMM_J:   immediate = imm_j;
            default: immediate = imm_i;
        endcase
    end

    assign auipc_result =
        pc + immediate;

    always @(*) begin
        case (wb_sel)
            WB_MEM:   write_back_data = memory_read_data;
            WB_PC4:   write_back_data = pc_plus_4;
            WB_IMM_U: write_back_data = immediate;
            WB_AUIPC: write_back_data = auipc_result;
            default:  write_back_data = alu_result;
        endcase
    end

    assign registers_equal =
        read_data1 == read_data2;

    always @(*) begin
        case (branch_type)
            BR_EQ:
                branch_condition = read_data1 == read_data2;
            BR_NE:
                branch_condition = read_data1 != read_data2;
            BR_LT:
                branch_condition = $signed(read_data1) < $signed(read_data2);
            BR_GE:
                branch_condition = $signed(read_data1) >= $signed(read_data2);
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

    assign jump_target = pc + immediate;
    assign jalr_target = {alu_result[31:1], 1'b0};

    assign next_pc =
        jump
            ? jump_target
            : jump_reg
                ? jalr_target
            : branch_taken
                ? branch_target
                : pc_plus_4;

endmodule
