module pipeline_cpu (
    input wire clk,
    input wire reset
);

    // ============================================================
    // IF stage
    // ============================================================

    wire [31:0] pc;
    wire [31:0] next_pc;
    wire [31:0] instruction;
    wire [31:0] pc_plus_4;

    assign pc_plus_4 = pc + 32'd4;

    // For now:
    // no branch / jump / trap.
    assign next_pc = pc_plus_4;

    program_counter pc0 (
        .clk(clk),
        .reset(reset),
        .next_pc(next_pc),
        .pc(pc)
    );

    instruction_memory imem (
        .address(pc),
        .instruction(instruction)
    );


    // ============================================================
    // IF / ID pipeline register
    // ============================================================

    reg [31:0] if_id_pc;
    reg [31:0] if_id_pc_plus_4;
    reg [31:0] if_id_instruction;
    reg        if_id_valid;

    always @(posedge clk) begin
        if (reset) begin
            if_id_pc          <= 32'd0;
            if_id_pc_plus_4   <= 32'd0;
            if_id_instruction <= 32'h00000013; // NOP
            if_id_valid       <= 1'b0;
        end else begin
            if_id_pc          <= pc;
            if_id_pc_plus_4   <= pc_plus_4;
            if_id_instruction <= instruction;
            if_id_valid       <= 1'b1;
        end
    end

endmodule
