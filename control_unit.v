module control_unit (
    input  wire [6:0] opcode,
    input  wire [2:0] funct3,

    output reg reg_write,
    output reg mem_write,
    output reg alu_src_imm,
    output reg mem_to_reg,
    output reg branch,
    output reg jump,
    output reg jalr
);

    always @(*) begin
        reg_write   = 0;
        mem_write   = 0;
        alu_src_imm = 0;
        mem_to_reg  = 0;
        branch      = 0;
        jump        = 0;
        jalr        = 0;

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

            // BEQ
            7'b1100011: begin
                if (funct3 == 3'b000) begin
                    branch = 1;
                end
            end

            // JALR
            7'b1100111: begin
                if (funct3 == 3'b000) begin
                    reg_write   = 1;
                    alu_src_imm = 1;
                    jalr        = 1;
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
