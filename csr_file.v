module csr_file (
    input  wire        clk,
    input  wire        reset,

    input  wire        trap,
    input  wire [31:0] trap_pc,
    input  wire [31:0] trap_cause,
    input  wire [31:0] trap_value,
    input  wire        is_mret,
    input  wire        external_irq,

    input  wire [11:0] csr_addr,
    input  wire [1:0]  csr_cmd,
    input  wire        csr_write_enable,
    input  wire [31:0] csr_write_data,

    output reg  [31:0] csr_read_data,
    output reg  [31:0] mstatus,
    output reg  [31:0] mie,
    output reg  [31:0] mtvec,
    output reg  [31:0] mepc,
    output reg  [31:0] mcause,
    output reg  [31:0] mtval,
    output wire [31:0] mip
);

    localparam CSR_NONE = 2'b00;
    localparam CSR_RW   = 2'b01;
    localparam CSR_RS   = 2'b10;
    localparam CSR_RC   = 2'b11;

    localparam CSR_MSTATUS = 12'h300;
    localparam CSR_MIE     = 12'h304;
    localparam CSR_MTVEC   = 12'h305;
    localparam CSR_MEPC    = 12'h341;
    localparam CSR_MCAUSE  = 12'h342;
    localparam CSR_MTVAL   = 12'h343;
    localparam CSR_MIP     = 12'h344;

    localparam MSTATUS_MIE  = 32'h00000008; // bit 3
    localparam MSTATUS_MPIE = 32'h00000080; // bit 7
    localparam MSTATUS_MASK = MSTATUS_MIE | MSTATUS_MPIE;

    localparam MIE_MEIE = 32'h00000800; // bit 11
    localparam MIP_MEIP = 32'h00000800;

    assign mip =
        external_irq
            ? MIP_MEIP
            : 32'd0;

    // CSR read
    always @(*) begin
        case (csr_addr)
            CSR_MSTATUS: csr_read_data = mstatus;
            CSR_MIE:     csr_read_data = mie;
            CSR_MTVEC:   csr_read_data = mtvec;
            CSR_MEPC:    csr_read_data = mepc;
            CSR_MCAUSE:  csr_read_data = mcause;
            CSR_MTVAL:   csr_read_data = mtval;
            CSR_MIP:     csr_read_data = mip;
            default:     csr_read_data = 32'd0;
        endcase
    end

    // CSR write
    always @(posedge clk) begin
        if (reset) begin
            mstatus <= 32'd0;
            mie     <= 32'd0;
            mtvec   <= 32'h00000100;
            mepc    <= 32'd0;
            mcause  <= 32'd0;
            mtval   <= 32'd0;
        end else if (trap) begin
            mepc   <= trap_pc & 32'hfffffffc;
            mcause <= trap_cause;
            mtval  <= trap_value;

            // MPIE <- MIE, MIE <- 0
            mstatus[7] <= mstatus[3];
            mstatus[3] <= 1'b0;
        end else if (is_mret) begin
            // MIE <- MPIE, MPIE <- 1
            mstatus[3] <= mstatus[7];
            mstatus[7] <= 1'b1;
        end else if (csr_write_enable) begin
            case (csr_addr)
                CSR_MSTATUS: begin
                    case (csr_cmd)
                        CSR_RW:
                            mstatus <=
                                csr_write_data & MSTATUS_MASK;
                        CSR_RS:
                            mstatus <=
                                (mstatus | csr_write_data)
                                & MSTATUS_MASK;
                        CSR_RC:
                            mstatus <=
                                (mstatus & ~csr_write_data)
                                & MSTATUS_MASK;
                    endcase
                end
                CSR_MIE: begin
                    case (csr_cmd)
                        CSR_RW:
                            mie <= csr_write_data & MIE_MEIE;
                        CSR_RS:
                            mie <= (mie | csr_write_data)
                                   & MIE_MEIE;
                        CSR_RC:
                            mie <= (mie & ~csr_write_data)
                                   & MIE_MEIE;
                    endcase
                end
                CSR_MTVEC: begin
                    case (csr_cmd)
                        CSR_RW:
                            mtvec <= csr_write_data & 32'hfffffffc;
                        CSR_RS:
                            mtvec <=
                                (mtvec | csr_write_data)
                                & 32'hfffffffc;
                        CSR_RC:
                            mtvec <=
                                (mtvec & ~csr_write_data)
                                & 32'hfffffffc;
                    endcase
                end
                CSR_MEPC: begin
                    case (csr_cmd)
                        CSR_RW:
                            mepc <= csr_write_data & 32'hfffffffc;
                        CSR_RS:
                            mepc <=
                                (mepc | csr_write_data)
                                & 32'hfffffffc;
                        CSR_RC:
                            mepc <=
                                (mepc & ~csr_write_data)
                                & 32'hfffffffc;
                    endcase
                end
                CSR_MCAUSE: begin
                    case (csr_cmd)
                        CSR_RW: mcause <= csr_write_data;
                        CSR_RS: mcause <= mcause | csr_write_data;
                        CSR_RC: mcause <= mcause & ~csr_write_data;
                    endcase
                end
                CSR_MTVAL: begin
                    case (csr_cmd)
                        CSR_RW: mtval <= csr_write_data;
                        CSR_RS: mtval <= mtval | csr_write_data;
                        CSR_RC: mtval <= mtval & ~csr_write_data;
                    endcase
                end
            endcase
        end
    end

endmodule
