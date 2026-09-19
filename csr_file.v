module csr_file (
    input  wire        clk,
    input  wire        reset,

    input  wire        trap,
    input  wire [31:0] trap_pc,
    input  wire [31:0] trap_cause,
    input  wire [31:0] trap_value,

    input  wire [11:0] csr_addr,
    input  wire [1:0]  csr_cmd,
    input  wire        csr_write_enable,
    input  wire [31:0] csr_write_data,

    output reg  [31:0] csr_read_data,
    output reg  [31:0] mtvec,
    output reg  [31:0] mepc,
    output reg  [31:0] mcause,
    output reg  [31:0] mtval
);

    localparam CSR_NONE = 2'b00;
    localparam CSR_RW   = 2'b01;
    localparam CSR_RS   = 2'b10;
    localparam CSR_RC   = 2'b11;

    localparam CSR_MTVEC  = 12'h305;
    localparam CSR_MEPC   = 12'h341;
    localparam CSR_MCAUSE = 12'h342;
    localparam CSR_MTVAL  = 12'h343;

    // CSR read
    always @(*) begin
        case (csr_addr)
            CSR_MTVEC:
                csr_read_data = mtvec;
            CSR_MEPC:
                csr_read_data = mepc;
            CSR_MCAUSE:
                csr_read_data = mcause;
            CSR_MTVAL:
                csr_read_data = mtval;
            default:
                csr_read_data = 32'd0;
        endcase
    end

    // CSR write
    always @(posedge clk) begin
        if (reset) begin
            mtvec  <= 32'h00000100;
            mepc   <= 32'd0;
            mcause <= 32'd0;
            mtval  <= 32'd0;
        end else if (trap) begin
            mepc   <= trap_pc;
            mcause <= trap_cause;
            mtval  <= trap_value;
        end else if (csr_write_enable) begin
            case (csr_addr)
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
                        CSR_RW: mepc <= csr_write_data;
                        CSR_RS: mepc <= mepc | csr_write_data;
                        CSR_RC: mepc <= mepc & ~csr_write_data;
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
