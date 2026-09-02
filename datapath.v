module datapath (
    input wire clk
);

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

endmodule
