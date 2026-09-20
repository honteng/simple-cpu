module simple_cpu (
    input wire clk,
    input wire reset,
    input wire external_irq
);

    wire [31:0] mstatus;
    wire [31:0] mie;
    wire [31:0] mip;
    wire [31:0] mtvec;
    wire [31:0] mepc;
    wire [31:0] mcause;
    wire [31:0] mtval;
    wire [31:0] csr_read_data;
    wire [11:0] csr_addr;
    wire [1:0] csr_cmd;
    wire csr_write_enable;

    wire [31:0] pc;
    wire [31:0] next_pc;
    wire [31:0] next_pc_no_trap;
    wire [31:0] instruction;
    wire is_mret;
    wire illegal_instruction;
    wire illegal_alu_instruction;
    wire [31:0] exception_cause;
    wire [31:0] exception_value;
    wire [31:0] interrupt_cause;
    wire [31:0] final_trap_cause;
    wire [31:0] final_trap_value;
    wire [31:0] trap_pc;

    assign csr_addr =
        instruction[31:20];

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
    wire [3:0] alu_op;

    wire [31:0] memory_read_data;
    reg [31:0] write_back_data;
    wire [31:0] auipc_result;
    wire [31:0] control_target;
    wire instruction_address_misaligned;

    wire reg_write;
    wire effective_reg_write;
    wire mem_write;
    wire effective_mem_write;
    wire mem_misaligned;
    wire load_access;
    wire store_access;
    wire load_misaligned;
    wire store_misaligned;
    wire exception_trap;
    wire take_interrupt;
    wire take_trap;
    wire [1:0] mem_size;
    wire load_unsigned;
    wire alu_src_imm;
    wire [2:0] imm_sel;
    wire [2:0] wb_sel;
    wire branch;
    wire jump;
    wire jump_reg;
    wire [2:0] branch_type;

    wire [31:0] pc_plus_4;

    localparam WB_ALU   = 3'b000;
    localparam WB_MEM   = 3'b001;
    localparam WB_PC4   = 3'b010;
    localparam WB_IMM_U = 3'b011;
    localparam WB_AUIPC = 3'b100;
    localparam WB_CSR   = 3'b101;

    localparam CSR_NONE = 2'b00;
    localparam CSR_RW   = 2'b01;
    localparam CSR_RS   = 2'b10;
    localparam CSR_RC   = 2'b11;

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
        .mem_size(mem_size),
        .load_unsigned(load_unsigned),
        .alu_src_imm(alu_src_imm),
        .imm_sel(imm_sel),
        .wb_sel(wb_sel),
        .csr_cmd(csr_cmd),
        .branch(branch),
        .jump(jump),
        .jump_reg(jump_reg),
        .branch_type(branch_type),
        .illegal_instruction(illegal_instruction)
    );

    register_file rf (
        .clk(clk),
        .write_enable(effective_reg_write),
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
        .alu_op(alu_op),
        .illegal_alu_instruction(illegal_alu_instruction)
    );

    alu alu0 (
        .a(read_data1),
        .b(alu_input_b),
        .op(alu_op),
        .result(alu_result)
    );

    data_memory dmem (
        .clk(clk),
        .mem_write(effective_mem_write),
        .mem_size(mem_size),
        .load_unsigned(load_unsigned),
        .address(alu_result),
        .write_data(read_data2),
        .read_data(memory_read_data),
        .misaligned(mem_misaligned)
    );

    assign load_access =
        (wb_sel == WB_MEM);

    assign store_access =
        mem_write;

    assign load_misaligned =
        load_access && mem_misaligned;

    assign store_misaligned =
        store_access && mem_misaligned;

    trap_controller trap_ctl (
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
        .memory_address(alu_result),

        .is_mret(is_mret),
        .trap(exception_trap),
        .trap_cause(exception_cause),
        .trap_value(exception_value)
    );

    interrupt_controller irq_ctl (
        .mstatus(mstatus),
        .mie(mie),
        .mip(mip),

        .exception_trap(exception_trap),

        .take_interrupt(take_interrupt),
        .interrupt_cause(interrupt_cause)
    );

    assign take_trap =
        exception_trap ||
        take_interrupt;

    assign trap_pc =
        exception_trap
            ? pc
            : next_pc_no_trap;

    assign final_trap_cause =
        exception_trap
            ? exception_cause
            : interrupt_cause;

    assign final_trap_value =
        exception_trap
            ? exception_value
            : 32'd0;

    control_flow_unit flow (
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

    // CSRRS/CSRRC with rs1 = x0 read the CSR without writing it.
    assign csr_write_enable =
        (csr_cmd == CSR_RW) ||
        (
            (csr_cmd == CSR_RS || csr_cmd == CSR_RC)
            && rs1 != 5'd0
        );

    csr_file csr0 (
        .clk(clk),
        .reset(reset),
        .trap(take_trap),
        .trap_pc(trap_pc),
        .trap_cause(final_trap_cause),
        .trap_value(final_trap_value),
        .is_mret(is_mret),
        .external_irq(external_irq),
        .csr_addr(csr_addr),
        .csr_cmd(csr_cmd),
        .csr_write_enable(csr_write_enable),
        .csr_write_data(read_data1),
        .csr_read_data(csr_read_data),
        .mstatus(mstatus),
        .mie(mie),
        .mtvec(mtvec),
        .mepc(mepc),
        .mcause(mcause),
        .mtval(mtval),
        .mip(mip)
    );

    assign effective_reg_write =
        reg_write && !exception_trap;

    assign effective_mem_write =
        mem_write && !exception_trap;

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
            WB_CSR:   write_back_data = csr_read_data;
            default:  write_back_data = alu_result;
        endcase
    end

endmodule
