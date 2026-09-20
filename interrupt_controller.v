module interrupt_controller (
    input wire [31:0] mstatus,
    input wire [31:0] mie,
    input wire [31:0] mip,

    input wire exception_trap,

    output wire take_interrupt,
    output wire [31:0] interrupt_cause
);

    wire external_interrupt_pending;
    wire timer_interrupt_pending;

    assign external_interrupt_pending =
        mstatus[3] &&
        mie[11] &&
        mip[11];

    assign timer_interrupt_pending =
        mstatus[3] &&
        mie[7] &&
        mip[7];

    assign take_interrupt =
        !exception_trap &&
        (
            external_interrupt_pending ||
            timer_interrupt_pending
        );

    assign interrupt_cause =
        external_interrupt_pending
            ? 32'h8000000b
            : timer_interrupt_pending
                ? 32'h80000007
                : 32'd0;

endmodule
