module interrupt_controller (
    input wire external_irq,

    input wire [31:0] mstatus,
    input wire [31:0] mie,

    input wire exception_trap,

    output wire take_interrupt,
    output wire [31:0] interrupt_cause
);

    wire global_interrupt_enable;
    wire external_interrupt_enable;

    assign global_interrupt_enable =
        mstatus[3]; // MIE

    assign external_interrupt_enable =
        mie[11]; // MEIE

    assign take_interrupt =
        external_irq              &&
        global_interrupt_enable   &&
        external_interrupt_enable &&
        !exception_trap;

    // bit 31 = interrupt
    // code 11 = Machine External Interrupt
    assign interrupt_cause =
        32'h8000000b;

endmodule
