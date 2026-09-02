`timescale 1ns/1ps

module alu_tb;

    reg  [31:0] a;
    reg  [31:0] b;
    reg  [2:0]  op;

    wire [31:0] result;
    wire        zero;

    alu dut (
        .a(a),
        .b(b),
        .op(op),
        .result(result),
        .zero(zero)
    );

    initial begin
        $dumpfile("alu.vcd");
        $dumpvars(0, alu_tb);

        a = 0;
        b = 0;
        op = 0;
        #10;

        a = 10;
        b = 20;
        op = 3'b000; // ADD
        #10;

        a = 20;
        b = 10;
        op = 3'b001; // SUB
        #10;

        a = 10;
        b = 10;
        op = 3'b001; // SUB -> zero
        #10;

        a = 32'hF0F0;
        b = 32'h0FF0;
        op = 3'b010; // AND
        #10;

        $finish;
    end

endmodule