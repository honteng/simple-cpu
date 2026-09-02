`timescale 1ns/1ps

module instruction_decoder_tb;

    reg [31:0] instruction;

    wire [6:0] opcode;
    wire [4:0] rd;
    wire [4:0] rs1;
    wire [4:0] rs2;
    wire [2:0] funct3;
    wire [6:0] funct7;

    instruction_decoder decoder (
        .instruction(instruction),
        .opcode(opcode),
        .rd(rd),
        .rs1(rs1),
        .rs2(rs2),
        .funct3(funct3),
        .funct7(funct7)
    );

    initial begin
        $dumpfile("instruction_decoder.vcd");
        $dumpvars(0, instruction_decoder_tb);

        // add x3, x1, x2
        instruction = 32'h002081b3;

        #1;

        $display("instruction = %h", instruction);
        $display("opcode      = %b", opcode);
        $display("rd          = %d", rd);
        $display("rs1         = %d", rs1);
        $display("rs2         = %d", rs2);
        $display("funct3      = %b", funct3);
        $display("funct7      = %b", funct7);

        $finish;
    end

endmodule