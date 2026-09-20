module interrupt_controller (
    input wire [31:0] mstatus,
    input wire [31:0] mie,
    input wire [31:0] mip,

    input wire exception_trap,

    output wire take_interrupt,
    output wire [31:0] interrupt_cause
);

    wire global_interrupt_enable;
    wire external_interrupt_enable;
    wire external_interrupt_pending;

    assign global_interrupt_enable =
        mstatus[3]; // MIE

    assign external_interrupt_enable =
        mie[11]; // MEIE

    assign external_interrupt_pending =
        mip[11]; // MEIP

    assign take_interrupt =
        global_interrupt_enable   &&
        external_interrupt_enable &&
        external_interrupt_pending &&
        !exception_trap;

    // bit 31 = interrupt
    // code 11 = Machine External Interrupt
    assign interrupt_cause =
        32'h8000000b;

endmodule
