`timescale 1ns/1ps

module simple_tb;

    reg signal;

    initial begin
        $dumpfile("simple.vcd");
        $dumpvars(0, simple_tb);

        signal = 0;
        #10;

        signal = 1;
        #10;

        signal = 0;
        #10;

        $finish;
    end

endmodule