module alu_control (
	input wire [6:0] opcode,
	input wire [2:0] funct3,
	input wire [6:0] funct7,
	output reg [2:0] alu_op
);

	always @(*) begin
		// default: ADD
		alu_op = 3'b000;

		case (opcode)
		 // R-type instructions
			7'b0110011: begin // R-type
				case (funct3)
					3'b000: begin
                                                if (funct7 == 7'b0100000)
                                                    alu_op = 3'b001; // SUB
                                                else
                                                    alu_op = 3'b000; // ADD
					end
					3'b111: alu_op = 3'b010; // AND
					3'b110: alu_op = 3'b011; // OR
					3'b100: alu_op = 3'b100; // XOR
					3'b010: alu_op = 3'b101; // SLT
					3'b011: alu_op = 3'b110; // SLTU
					default:
						alu_op = 3'b000;
				endcase
			end

			// I-type ALU instructions
			7'b0010011: begin
				case (funct3)
					3'b000: alu_op = 3'b000; // ADDI
					3'b010: alu_op = 3'b101; // SLTI
					3'b011: alu_op = 3'b110; // SLTIU
					default: alu_op = 3'b000;
				endcase
			end

			// LW
			7'b0000011: alu_op = 3'b000; // ADD for address calculation

			// SW
			7'b0100011: alu_op = 3'b000; // ADD for address calculation

			// JALR
			7'b1100111: alu_op = 3'b000; // ADD for target calculation

			default: begin
				alu_op = 3'b000; // default: ADD
			end
		endcase
	end
endmodule
