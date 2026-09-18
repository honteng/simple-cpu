module control_unit (
    input  wire [6:0] opcode,
    input  wire [2:0] funct3,

    output reg reg_write,
    output reg mem_write,
    output reg [1:0] mem_size,
    output reg load_unsigned,
    output reg alu_src_imm,
    output reg [2:0] imm_sel,
    output reg [2:0] wb_sel,
    output reg [1:0] csr_cmd,
    output reg branch,
    output reg jump,
    output reg jump_reg,
    output reg [2:0] branch_type,
    output reg illegal_instruction
);

    localparam MEM_BYTE = 2'b00;
    localparam MEM_HALF = 2'b01;
    localparam MEM_WORD = 2'b10;

    localparam CSR_NONE = 2'b00;
    localparam CSR_RW   = 2'b01;
    localparam CSR_RS   = 2'b10;
    localparam CSR_RC   = 2'b11;

    localparam WB_ALU   = 3'b000;
    localparam WB_MEM   = 3'b001;
    localparam WB_PC4   = 3'b010;
    localparam WB_IMM_U = 3'b011;
    localparam WB_AUIPC = 3'b100;
    localparam WB_CSR   = 3'b101;

    localparam IMM_I = 3'b000;
    localparam IMM_S = 3'b001;
    localparam IMM_B = 3'b010;
    localparam IMM_U = 3'b011;
    localparam IMM_J = 3'b100;

    localparam BR_NONE = 3'b000;
    localparam BR_EQ   = 3'b001;
    localparam BR_NE   = 3'b010;
    localparam BR_LT   = 3'b011;
    localparam BR_GE   = 3'b100;

    always @(*) begin
        reg_write   = 0;
        mem_write   = 0;
        mem_size      = MEM_WORD;
        load_unsigned = 0;
        alu_src_imm = 0;
        imm_sel     = IMM_I;
        wb_sel      = WB_ALU;
        csr_cmd     = CSR_NONE;
        branch      = 0;
        jump        = 0;
        jump_reg    = 0;
        branch_type = BR_NONE;
        illegal_instruction = 1;

        case (opcode)

            // R type
            7'b0110011: begin
                illegal_instruction = 0;
                reg_write = 1;
            end

            // I-type ALU instructions: ADDI, SLTI, SLTIU
            7'b0010011: begin
                illegal_instruction = 0;
                reg_write   = 1;
                alu_src_imm = 1;
                imm_sel     = IMM_I;
            end

            // LUI
            7'b0110111: begin
                illegal_instruction = 0;
                reg_write = 1;
                imm_sel   = IMM_U;
                wb_sel    = WB_IMM_U;
            end

            // AUIPC
            7'b0010111: begin
                illegal_instruction = 0;
                reg_write = 1;
                imm_sel   = IMM_U;
                wb_sel    = WB_AUIPC;
            end

            // Loads
            7'b0000011: begin
                reg_write   = 1;
                alu_src_imm = 1;
                wb_sel      = WB_MEM;
                imm_sel     = IMM_I;

                case (funct3)
                    3'b000: begin // LB
                        illegal_instruction = 0;
                        mem_size      = MEM_BYTE;
                        load_unsigned = 0;
                    end
                    3'b001: begin // LH
                        illegal_instruction = 0;
                        mem_size      = MEM_HALF;
                        load_unsigned = 0;
                    end
                    3'b010: begin // LW
                        illegal_instruction = 0;
                        mem_size      = MEM_WORD;
                        load_unsigned = 0;
                    end
                    3'b100: begin // LBU
                        illegal_instruction = 0;
                        mem_size      = MEM_BYTE;
                        load_unsigned = 1;
                    end
                    3'b101: begin // LHU
                        illegal_instruction = 0;
                        mem_size      = MEM_HALF;
                        load_unsigned = 1;
                    end
                endcase
            end

            // Stores
            7'b0100011: begin
                mem_write   = 1;
                alu_src_imm = 1;
                imm_sel     = IMM_S;

                case (funct3)
                    3'b000: begin
                        illegal_instruction = 0;
                        mem_size = MEM_BYTE; // SB
                    end
                    3'b001: begin
                        illegal_instruction = 0;
                        mem_size = MEM_HALF; // SH
                    end
                    3'b010: begin
                        illegal_instruction = 0;
                        mem_size = MEM_WORD; // SW
                    end
                endcase
            end

            // Branches
            7'b1100011: begin
                branch = 1;
                imm_sel = IMM_B;
                case (funct3)
                    3'b000: begin
                        illegal_instruction = 0;
                        branch_type = BR_EQ; // BEQ
                    end
                    3'b001: begin
                        illegal_instruction = 0;
                        branch_type = BR_NE; // BNE
                    end
                    3'b100: begin
                        illegal_instruction = 0;
                        branch_type = BR_LT; // BLT
                    end
                    3'b101: begin
                        illegal_instruction = 0;
                        branch_type = BR_GE; // BGE
                    end
                    default: begin
                        branch = 0;
                        branch_type = BR_NONE;
                    end
                endcase
            end

            // JALR
            7'b1100111: begin
                if (funct3 == 3'b000) begin
                    illegal_instruction = 0;
                    reg_write   = 1;
                    alu_src_imm = 1;
                    imm_sel     = IMM_I;
                    jump_reg    = 1;
                    wb_sel      = WB_PC4;
                end
            end

            // JAL
            7'b1101111: begin
                illegal_instruction = 0;
                reg_write = 1;
                imm_sel   = IMM_J;
                jump      = 1;
                wb_sel    = WB_PC4;
            end
            // CSR instructions
            7'b1110011: begin
                case (funct3)
                    3'b000: begin // ECALL, EBREAK, MRET
                        illegal_instruction = 0;
                    end
                    3'b001: begin // CSRRW
                        illegal_instruction = 0;
                        reg_write = 1;
                        wb_sel    = WB_CSR;
                        csr_cmd   = CSR_RW;
                    end
                    3'b010: begin // CSRRS
                        illegal_instruction = 0;
                        reg_write = 1;
                        wb_sel    = WB_CSR;
                        csr_cmd   = CSR_RS;
                    end
                    3'b011: begin // CSRRC
                        illegal_instruction = 0;
                        reg_write = 1;
                        wb_sel    = WB_CSR;
                        csr_cmd   = CSR_RC;
                    end
                endcase
            end
        endcase
    end

endmodule
