module csr_file (
    input  wire        clk,
    input  wire        reset,

    input  wire        trap,
    input  wire [31:0] trap_pc,
    input  wire        is_ebreak,
    input  wire        load_misaligned,
    input  wire        store_misaligned,
    input  wire        is_ecall,

    input  wire [11:0] csr_addr,
    input  wire [1:0]  csr_cmd,
    input  wire        csr_write_enable,
    input  wire [31:0] csr_write_data,

    output reg  [31:0] csr_read_data,
    output reg  [31:0] mepc,
    output reg  [31:0] mcause
);

    localparam CSR_NONE = 2'b00;
    localparam CSR_RW   = 2'b01;
    localparam CSR_RS   = 2'b10;
    localparam CSR_RC   = 2'b11;

    localparam CSR_MEPC   = 12'h341;
    localparam CSR_MCAUSE = 12'h342;

    // CSR read
    always @(*) begin
        case (csr_addr)
            CSR_MEPC:
                csr_read_data = mepc;
            CSR_MCAUSE:
                csr_read_data = mcause;
            default:
                csr_read_data = 32'd0;
        endcase
    end

    // CSR write
    always @(posedge clk) begin
        if (reset) begin
            mepc   <= 32'd0;
            mcause <= 32'd0;
        end else if (trap) begin
            mepc <= trap_pc;

            if (is_ebreak)
                mcause <= 32'd3;
            else if (load_misaligned)
                mcause <= 32'd4;
            else if (store_misaligned)
                mcause <= 32'd6;
            else if (is_ecall)
                mcause <= 32'd11;
        end else if (csr_write_enable) begin
            case (csr_addr)
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
            endcase
        end
    end

endmodule
