module alu_control (
	input wire [6:0] opcode,
	input wire [2:0] funct3,
	input wire [6:0] funct7,
	output reg [2:0] alu_op
);

	localparam ALU_ADD  = 3'b000;
	localparam ALU_SUB  = 3'b001;
	localparam ALU_AND  = 3'b010;
	localparam ALU_OR   = 3'b011;
	localparam ALU_XOR  = 3'b100;
	localparam ALU_SLT  = 3'b101;
	localparam ALU_SLTU = 3'b110;

	always @(*) begin
		// default: ADD
		alu_op = ALU_ADD;

		case (opcode)
		 // R-type instructions
			7'b0110011: begin // R-type
				case (funct3)
					3'b000: begin
                                                if (funct7 == 7'b0100000)
                                                    alu_op = ALU_SUB;
                                                else
                                                    alu_op = ALU_ADD;
					end
					3'b111: alu_op = ALU_AND;
					3'b110: alu_op = ALU_OR;
					3'b100: alu_op = ALU_XOR;
					3'b010: alu_op = ALU_SLT;
					3'b011: alu_op = ALU_SLTU;
					default:
						alu_op = ALU_ADD;
				endcase
			end

			// I-type ALU instructions
			7'b0010011: begin
				case (funct3)
					3'b000: alu_op = ALU_ADD; // ADDI
					3'b010: alu_op = ALU_SLT; // SLTI
					3'b011: alu_op = ALU_SLTU; // SLTIU
					default: alu_op = ALU_ADD;
				endcase
			end

			// LW
			7'b0000011: alu_op = ALU_ADD; // ADD for address calculation

			// SW
			7'b0100011: alu_op = ALU_ADD; // ADD for address calculation

			// JALR
			7'b1100111: alu_op = ALU_ADD; // ADD for target calculation

			default: begin
				alu_op = ALU_ADD;
			end
		endcase
	end
endmodule
