module control_unit (
    input  wire [6:0] opcode,
    input  wire [2:0] funct3,

    output reg reg_write,
    output reg mem_write,
    output reg alu_src_imm,
    output reg mem_to_reg,
    output reg branch,
    output reg jump,
    output reg jump_reg,
    output reg use_lui,
    output reg use_auipc,
    output reg [2:0] branch_type
);

    localparam BR_NONE = 3'b000;
    localparam BR_EQ   = 3'b001;
    localparam BR_NE   = 3'b010;
    localparam BR_LT   = 3'b011;
    localparam BR_GE   = 3'b100;

    always @(*) begin
        reg_write   = 0;
        mem_write   = 0;
        alu_src_imm = 0;
        mem_to_reg  = 0;
        branch      = 0;
        jump        = 0;
        jump_reg    = 0;
        use_lui     = 0;
        use_auipc   = 0;
        branch_type = BR_NONE;

        case (opcode)

            // R type
            7'b0110011: begin
                reg_write = 1;
            end

            // ADDI
            7'b0010011: begin
                reg_write   = 1;
                alu_src_imm = 1;
            end

            // LUI
            7'b0110111: begin
                reg_write = 1;
                use_lui   = 1;
            end

            // AUIPC
            7'b0010111: begin
                reg_write = 1;
                use_auipc = 1;
            end

            // LW
            7'b0000011: begin
                if (funct3 == 3'b010) begin
                    reg_write   = 1;
                    alu_src_imm = 1;
                    mem_to_reg  = 1;
                end
            end

            // SW
            7'b0100011: begin
                if (funct3 == 3'b010) begin
                    mem_write   = 1;
                    alu_src_imm = 1;
                end
            end

            // Branches
            7'b1100011: begin
                case (funct3)
                    3'b000: begin
                        branch_type = BR_EQ; // BEQ
                        branch = 1;
                    end
                    3'b001: branch_type = BR_NE; // BNE
                    3'b100: branch_type = BR_LT; // BLT
                    3'b101: branch_type = BR_GE; // BGE
                endcase
            end

            // JALR
            7'b1100111: begin
                if (funct3 == 3'b000) begin
                    reg_write   = 1;
                    alu_src_imm = 1;
                    jump_reg    = 1;
                end
            end

            // JAL
            7'b1101111: begin
                reg_write = 1;
                jump      = 1;
            end
        endcase
    end

endmodule
