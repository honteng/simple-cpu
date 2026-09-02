module cpu_core (
    input wire clk,
    input wire reset
);

    reg [31:0] instruction;

    wire [6:0] opcode;
    wire [4:0] rd;
    wire [4:0] rs1;
    wire [4:0] rs2;
    wire [2:0] funct3;
    wire [6:0] funct7;

    wire [31:0] read_data1;
    wire [31:0] read_data2;
    wire [31:0] alu_result;

    reg write_enable;

    instruction_decoder decoder (
        .instruction(instruction),
        .opcode(opcode),
        .rd(rd),
        .rs1(rs1),
        .rs2(rs2),
        .funct3(funct3),
        .funct7(funct7)
    );

    register_file rf (
        .clk(clk),
        .write_enable(write_enable),
        .read_addr1(rs1),
        .read_addr2(rs2),
        .write_addr(rd),
        .write_data(alu_result),
        .read_data1(read_data1),
        .read_data2(read_data2)
    );

    alu alu0 (
        .a(read_data1),
        .b(read_data2),
        .op(3'b000),
        .result(alu_result)
    );

    always @(*) begin
        write_enable = 0;

        if (
            opcode == 7'b0110011 &&
            funct3 == 3'b000 &&
            funct7 == 7'b0000000
        ) begin
            write_enable = 1;
        end
    end

endmodule