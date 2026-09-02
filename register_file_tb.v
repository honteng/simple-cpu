`timescale 1ns/1ps

module register_file_tb;

    reg clk;
    reg write_enable;

    reg [4:0] read_addr1;
    reg [4:0] read_addr2;

    reg [4:0] write_addr;
    reg [31:0] write_data;

    wire [31:0] read_data1;
    wire [31:0] read_data2;

    register_file uut (
        .clk(clk),
        .write_enable(write_enable),
        .read_addr1(read_addr1),
        .read_addr2(read_addr2),
        .write_addr(write_addr),
        .write_data(write_data),
        .read_data1(read_data1),
        .read_data2(read_data2)
    );

    // 10ns周期のclock
    always #5 clk = ~clk;

    initial begin
        $dumpfile("register_file.vcd");
        $dumpvars(0, register_file_tb);

        clk = 0;
        write_enable = 0;

        read_addr1 = 0;
        read_addr2 = 0;

        write_addr = 0;
        write_data = 0;

        // x1 = 10
        #2;
        write_enable = 1;
        write_addr = 5'd1;
        write_data = 32'd10;

        #8;

        // x2 = 20
        write_addr = 5'd2;
        write_data = 32'd20;

        #10;

        write_enable = 0;

        // x1とx2を読む
        read_addr1 = 5'd1;
        read_addr2 = 5'd2;

        #1;

        $display("x1 = %d", read_data1);
        $display("x2 = %d", read_data2);

        // x0への書き込みを試す
        write_enable = 1;
        write_addr = 5'd0;
        write_data = 32'd999;

        #10;

        write_enable = 0;

        read_addr1 = 5'd0;

        #1;

        $display("x0 = %d", read_data1);

        $finish;
    end

endmodule
