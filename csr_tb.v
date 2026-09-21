`timescale 1ns/1ps

module csr_tb;

    reg clk;
    reg reset;

    reg trap;
    reg [31:0] trap_pc;
    reg [31:0] trap_cause;
    reg [31:0] trap_value;

    reg is_mret;
    reg external_irq;
    reg timer_irq;

    reg [11:0] csr_addr;
    reg [1:0] csr_cmd;
    reg csr_write_enable;
    reg [31:0] csr_write_data;

    wire [31:0] csr_read_data;

    wire [31:0] mstatus;
    wire [31:0] mie;
    wire [31:0] mtvec;
    wire [31:0] mepc;
    wire [31:0] mcause;
    wire [31:0] mtval;
    wire [31:0] mip;

    localparam CSR_RW = 2'b01;

    localparam CSR_MSTATUS = 12'h300;
    localparam CSR_MIE     = 12'h304;
    localparam CSR_MTVEC   = 12'h305;
    localparam CSR_MEPC    = 12'h341;
    localparam CSR_MCAUSE  = 12'h342;
    localparam CSR_MTVAL   = 12'h343;
    localparam CSR_MIP     = 12'h344;

    csr_file dut (
        .clk(clk),
        .reset(reset),

        .trap(trap),
        .trap_pc(trap_pc),
        .trap_cause(trap_cause),
        .trap_value(trap_value),

        .is_mret(is_mret),

        .external_irq(external_irq),
        .timer_irq(timer_irq),

        .csr_addr(csr_addr),
        .csr_cmd(csr_cmd),
        .csr_write_enable(csr_write_enable),
        .csr_write_data(csr_write_data),

        .csr_read_data(csr_read_data),

        .mstatus(mstatus),
        .mie(mie),
        .mtvec(mtvec),
        .mepc(mepc),
        .mcause(mcause),
        .mtval(mtval),
        .mip(mip)
    );

    always #5 clk = ~clk;

    task write_csr;
        input [11:0] addr;
        input [31:0] value;

        begin
            @(negedge clk);

            csr_addr = addr;
            csr_cmd = CSR_RW;
            csr_write_data = value;
            csr_write_enable = 1;

            @(posedge clk);
            #1;

            csr_write_enable = 0;
        end
    endtask

    initial begin

        clk = 0;
        reset = 1;

        trap = 0;
        trap_pc = 0;
        trap_cause = 0;
        trap_value = 0;

        is_mret = 0;

        external_irq = 0;
        timer_irq = 0;

        csr_addr = 0;
        csr_cmd = 0;
        csr_write_enable = 0;
        csr_write_data = 0;

        // Reset
        repeat (2) @(posedge clk);

        @(negedge clk);
        reset = 0;


        // ------------------------------------------------
        // mtvec alignment
        // ------------------------------------------------
        write_csr(CSR_MTVEC, 32'h00000183);

        if (mtvec !== 32'h00000180)
            $fatal(1, "mtvec alignment failed");


        // ------------------------------------------------
        // mepc alignment
        // ------------------------------------------------
        write_csr(CSR_MEPC, 32'h00000103);

        if (mepc !== 32'h00000100)
            $fatal(1, "mepc alignment failed");


        // ------------------------------------------------
        // mie MTIE + MEIE
        // ------------------------------------------------
        write_csr(CSR_MIE, 32'h00000880);

        if (mie !== 32'h00000880)
            $fatal(1, "mie write failed");


        // ------------------------------------------------
        // mip is driven from IRQ inputs
        // ------------------------------------------------
        external_irq = 1;
        timer_irq = 1;

        #1;

        if (mip !== 32'h00000880)
            $fatal(1, "mip pending bits failed");

        external_irq = 0;
        timer_irq = 0;


        // ------------------------------------------------
        // Enable global MIE
        // ------------------------------------------------
        write_csr(CSR_MSTATUS, 32'h00000008);

        if (mstatus !== 32'h00000008)
            $fatal(1, "mstatus MIE write failed");


        // ------------------------------------------------
        // Trap:
        //
        // MPIE <- MIE
        // MIE  <- 0
        // ------------------------------------------------
        @(negedge clk);

        trap = 1;
        trap_pc = 32'h00000044;
        trap_cause = 32'd2;
        trap_value = 32'hdeadbeef;

        @(posedge clk);
        #1;

        trap = 0;

        if (mstatus !== 32'h00000080)
            $fatal(1, "Trap mstatus transition failed");

        if (mepc !== 32'h00000044)
            $fatal(1, "Trap mepc failed");

        if (mcause !== 32'd2)
            $fatal(1, "Trap mcause failed");

        if (mtval !== 32'hdeadbeef)
            $fatal(1, "Trap mtval failed");


        // ------------------------------------------------
        // MRET:
        //
        // MIE  <- MPIE
        // MPIE <- 1
        // ------------------------------------------------
        @(negedge clk);

        is_mret = 1;

        @(posedge clk);
        #1;

        is_mret = 0;

        if (mstatus !== 32'h00000088)
            $fatal(1, "MRET mstatus restore failed");


        // ------------------------------------------------
        // CSR read
        // ------------------------------------------------
        csr_addr = CSR_MEPC;
        #1;

        if (csr_read_data !== mepc)
            $fatal(1, "CSR read failed");


        $display("PASS: csr_tb");
        $finish;
    end

endmodule
