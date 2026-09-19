module alu_control (
	input wire [6:0] opcode,
	input wire [2:0] funct3,
	input wire [6:0] funct7,
	output reg [3:0] alu_op,
	output reg illegal_alu_instruction
);

	localparam ALU_ADD  = 4'b0000;
	localparam ALU_SUB  = 4'b0001;
	localparam ALU_AND  = 4'b0010;
	localparam ALU_OR   = 4'b0011;
	localparam ALU_XOR  = 4'b0100;
	localparam ALU_SLT  = 4'b0101;
	localparam ALU_SLTU = 4'b0110;
	localparam ALU_SLL  = 4'b0111;
	localparam ALU_SRL  = 4'b1000;
	localparam ALU_SRA  = 4'b1001;

	always @(*) begin
		// default: ADD
		alu_op = ALU_ADD;
		illegal_alu_instruction = 0;

		case (opcode)
		 // R-type instructions
			7'b0110011: begin // R-type
				illegal_alu_instruction = 1;
				case (funct3)
					3'b000: begin
						if (funct7 == 7'b0000000) begin
							alu_op = ALU_ADD;
							illegal_alu_instruction = 0;
						end else if (funct7 == 7'b0100000) begin
							alu_op = ALU_SUB;
							illegal_alu_instruction = 0;
						end
					end
					3'b001: begin
						if (funct7 == 7'b0000000) begin
							alu_op = ALU_SLL;
							illegal_alu_instruction = 0;
						end
					end
					3'b010: begin
						if (funct7 == 7'b0000000) begin
							alu_op = ALU_SLT;
							illegal_alu_instruction = 0;
						end
					end
					3'b011: begin
						if (funct7 == 7'b0000000) begin
							alu_op = ALU_SLTU;
							illegal_alu_instruction = 0;
						end
					end
					3'b100: begin
						if (funct7 == 7'b0000000) begin
							alu_op = ALU_XOR;
							illegal_alu_instruction = 0;
						end
					end
					3'b101: begin
						if (funct7 == 7'b0000000) begin
							alu_op = ALU_SRL;
							illegal_alu_instruction = 0;
						end else if (funct7 == 7'b0100000) begin
							alu_op = ALU_SRA;
							illegal_alu_instruction = 0;
						end
					end
					3'b110: begin
						if (funct7 == 7'b0000000) begin
							alu_op = ALU_OR;
							illegal_alu_instruction = 0;
						end
					end
					3'b111: begin
						if (funct7 == 7'b0000000) begin
							alu_op = ALU_AND;
							illegal_alu_instruction = 0;
						end
					end
				endcase
			end

			// I-type ALU instructions
			7'b0010011: begin
				illegal_alu_instruction = 0;
				case (funct3)
					3'b000: alu_op = ALU_ADD; // ADDI
					3'b010: alu_op = ALU_SLT; // SLTI
					3'b011: alu_op = ALU_SLTU; // SLTIU
					3'b100: alu_op = ALU_XOR; // XORI
					3'b110: alu_op = ALU_OR; // ORI
					3'b111: alu_op = ALU_AND; // ANDI
					3'b001: begin
						if (funct7 == 7'b0000000)
							alu_op = ALU_SLL; // SLLI
						else
							illegal_alu_instruction = 1;
					end
					3'b101: begin
						if (funct7 == 7'b0000000)
							alu_op = ALU_SRL; // SRLI
						else if (funct7 == 7'b0100000)
							alu_op = ALU_SRA; // SRAI
						else
							illegal_alu_instruction = 1;
					end
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
