module data_memory (
	input wire clk,
	input wire mem_write,
	input wire [31:0] address,
	input wire [31:0] write_data,
	output wire [31:0] read_data
);

	reg [31:0] memory [0:255];

	assign read_data = memory[address[9:2]];

	always @(posedge clk) begin
		if (mem_write) begin
			memory[address[9:2]] <= write_data;
		end
	end
endmodule