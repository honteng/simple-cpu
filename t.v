module testbench;
    reg clk;
    reg [7:0] data;
    wire [7:0] result;

    // Instantiate your design under test
    my_design dut (
        .clk(clk),
        .data(data),
        .result(result)
    );

    initial begin
        // VCD generation commands
        $dumpfile("waveform.vcd");
        $dumpvars(0, testbench);

        // Your test sequence
        clk = 0;
        data = 8'h00;
        #100;

        data = 8'hAA;
        #20;

        $finish;
    end

    // Clock generation
    always #5 clk = ~clk;
endmodule
