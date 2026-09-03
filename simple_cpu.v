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
    wire [31:0] imm_j;

    wire [31:0] read_data1;
    wire [31:0] read_data2;

    wire [31:0] alu_input_b;
    wire [31:0] alu_result;
    wire [2:0] alu_op;

    wire [31:0] memory_read_data;
    wire [31:0] write_back_data;
    wire [31:0] jump_target;

    wire reg_write;
    wire mem_write;
    wire alu_src_imm;
    wire mem_to_reg;
    wire branch;
    wire jump;

    wire registers_equal;
    wire branch_taken;

    wire [31:0] pc_plus_4;
    wire [31:0] branch_target;

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
	.imm_j(imm_j)
    );

    control_unit control (
        .opcode(opcode),
        .funct3(funct3),
        .reg_write(reg_write),
        .mem_write(mem_write),
        .alu_src_imm(alu_src_imm),
        .mem_to_reg(mem_to_reg),
        .branch(branch),
	.jump(jump)
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
            ? (
                opcode == 7'b0100011
                    ? imm_s
                    : imm_i
              )
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

    assign write_back_data =
        jump
            ? pc_plus_4
            : mem_to_reg
                ? memory_read_data
                : alu_result;

    assign registers_equal =
        read_data1 == read_data2;

    assign branch_taken =
        branch && registers_equal;

    assign pc_plus_4 =
        pc + 32'd4;

    assign branch_target =
        pc + imm_b;

    assign jump_target = pc + imm_j;

    assign next_pc =
        jump
            ? jump_target
            : branch_taken
                ? branch_target
                : pc_plus_4;

endmodule