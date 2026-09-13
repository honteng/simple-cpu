module data_memory (
	input wire clk,
	input wire mem_write,
	input wire [1:0] mem_size,
	input wire load_unsigned,
	input wire [31:0] address,
	input wire [31:0] write_data,
	output reg [31:0] read_data
);

	reg [7:0] memory [0:1023];
	localparam MEM_BYTE = 2'b00;
	localparam MEM_HALF = 2'b01;
	localparam MEM_WORD = 2'b10;

	// Size encoding: byte = 00, halfword = 01, word = 10.
	always @(*) begin
		case (mem_size)
			MEM_BYTE: begin
				if (load_unsigned)
					read_data = {24'd0, memory[address]};
				else
					read_data = {{24{memory[address][7]}},
					             memory[address]};
			end
			MEM_HALF: begin
				if (load_unsigned)
					read_data = {
						16'd0,
						memory[address + 1],
						memory[address]
					};
				else
					read_data = {
						{16{memory[address + 1][7]}},
						memory[address + 1],
						memory[address]
					};
			end
			MEM_WORD: begin
				read_data = {
					memory[address + 3],
					memory[address + 2],
					memory[address + 1],
					memory[address]
				};
			end
			default: read_data = 32'd0;
		endcase
	end

	always @(posedge clk) begin
		if (mem_write) begin
			case (mem_size)
				MEM_BYTE: begin
					memory[address] <= write_data[7:0];
				end
				MEM_HALF: begin
					memory[address] <= write_data[7:0];
					memory[address + 1] <= write_data[15:8];
				end
				MEM_WORD: begin
					memory[address] <= write_data[7:0];
					memory[address + 1] <= write_data[15:8];
					memory[address + 2] <= write_data[23:16];
					memory[address + 3] <= write_data[31:24];
				end
			endcase
		end
	end
endmodule
