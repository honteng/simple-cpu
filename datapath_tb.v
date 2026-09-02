`timescale 1ns/1ps

module datapath_tb;

    reg clk;

    reg         write_enable;
    reg  [4:0]  read_addr1;
    reg  [4:0]  read_addr2;
    reg  [4:0]  write_addr;
    reg  [31:0] write_data;
    reg  [2:0]  alu_op;

    wire [31:0] read_data1;
    wire [31:0] read_data2;
    wire [31:0] alu_result;

    register_file rf (
        .clk(clk),
        .write_enable(write_enable),
        .read_addr1(read_addr1),
        .read_addr2(read_addr2),
        .write_addr(write_addr),
        .write_data(write_data),
        .read_data1(read_data1),
        .read_data2(read_data2)
    );

    alu alu0 (
        .a(read_data1),
        .b(read_data2),
        .op(alu_op),
        .result(alu_result)
    );

    always #5 clk = ~clk;

    initial begin
        $dumpfile("datapath.vcd");
        $dumpvars(0, datapath_tb);

        clk = 0;
        write_enable = 0;
        read_addr1 = 0;
        read_addr2 = 0;
        write_addr = 0;
        write_data = 0;
        alu_op = 3'b000;

        // x1 = 10
        #2;
        write_enable = 1;
        write_addr = 5'd1;
        write_data = 32'd10;

        // 5ns posedgeで x1 に書かれる
        #8;

        // x2 = 20
        write_addr = 5'd2;
        write_data = 32'd20;

        // 15ns posedgeで x2 に書かれる
        #10;

        write_enable = 0;

        // x1, x2 を ALU に入力
        read_addr1 = 5'd1;
        read_addr2 = 5'd2;
        alu_op = 3'b000; // ADD

        #1;

        $display(
            "ALU: %d + %d = %d",
            read_data1,
            read_data2,
            alu_result
        );

        // ALU resultをx3に書く
        write_enable = 1;
        write_addr = 5'd3;
        write_data = alu_result;

        // 次のposedgeを待つ
        #9;

        write_enable = 0;

        // x3を読む
        read_addr1 = 5'd3;

        #1;

        $display("x3 = %d", read_data1);

        $finish;
    end

endmodule
