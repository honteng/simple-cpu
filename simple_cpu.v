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

    wire [31:0] read_data1;
    wire [31:0] read_data2;

    wire [31:0] alu_input_b;
    wire [31:0] alu_result;
    wire [2:0] alu_op;

    wire [31:0] memory_read_data;
    wire [31:0] write_back_data;

    wire is_r_type;
    wire is_addi;
    wire is_lw;
    wire is_sw;
    wire is_beq;

    wire write_enable;
    wire mem_write;

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
        .imm_b(imm_b)
    );

    assign is_r_type =
        opcode == 7'b0110011;

    assign is_addi =
        opcode == 7'b0010011 &&
        funct3 == 3'b000;

    assign is_lw =
        opcode == 7'b0000011 &&
        funct3 == 3'b010;

    assign is_sw =
        opcode == 7'b0100011 &&
        funct3 == 3'b010;

    assign is_beq =
        opcode == 7'b1100011 &&
        funct3 == 3'b000;

    assign write_enable =
        is_r_type ||
        is_addi ||
        is_lw;

    assign mem_write =
        is_sw;

    register_file rf (
        .clk(clk),
        .write_enable(write_enable),
        .read_addr1(rs1),
        .read_addr2(rs2),
        .write_addr(rd),
        .write_data(write_back_data),
        .read_data1(read_data1),
        .read_data2(read_data2)
    );

    assign alu_input_b =
        is_sw   ? imm_s :
        is_addi ? imm_i :
        is_lw   ? imm_i :
                  read_data2;

    alu_control control (
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
        is_lw ? memory_read_data : alu_result;

    //
    // Branch logic
    //

    assign registers_equal =
        read_data1 == read_data2;

    assign branch_taken =
        is_beq && registers_equal;

    assign pc_plus_4 =
        pc + 32'd4;

    assign branch_target =
        pc + imm_b;

    assign next_pc =
        branch_taken
            ? branch_target
            : pc_plus_4;

endmodule