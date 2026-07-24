/// --------------------------------------------------------
/// glitch_free_mux.sv
/// Ken The Nugget
/// 25/06/2026
/// Glitch-Free Clock Switching
/// --------------------------------------------------------

// Use With Sync Clocks
module glitch_free_mux_sync (
    input   logic   clk1,
    input   logic   clk2,
    input   logic   rst_n,
    input   logic   sel,
    output  logic   clkout
);

    // --------------------------------------------------------
    // Internal Signal List
    // --------------------------------------------------------

    logic clk1_en;
    logic clk1_glitchfree;
    logic clk2_en;
    logic clk2_glitchfree;

    // --------------------------------------------------------
    // MUX Logic
    // --------------------------------------------------------

    always_ff @(posedge clk1 or negedge rst_n) begin
        if (~rst_n) clk1_en <= 1'b0;
        else clk1_en <= ~sel & ~clk2_en;
    end

    always_ff @(posedge clk2 or negedge rst_n) begin
        if (~rst_n) clk2_en <= 1'b0;
        else clk2_en <= sel & ~clk1_en;
    end

    assign clk1_glitchfree = clk1 & clk1_en & ~sel;
    assign clk2_glitchfree = clk2 & clk2_en & sel;

    // --------------------------------------------------------
    // Output Assignments
    // --------------------------------------------------------
    assign clkout = clk1_glitchfree | clk2_glitchfree;

endmodule

// Use With ASync Clocks
module glitch_free_mux_async (
    input   logic   clk1,
    input   logic   clk2,
    input   logic   rst_n,
    input   logic   sel,
    output  logic   clkout
);

    // --------------------------------------------------------
    // Internal Signal List
    // --------------------------------------------------------

    logic clk1_en_stg1;
    logic clk1_en_stg2;
    logic clk1_glitchfree;
    logic clk2_en_stg1;
    logic clk2_en_stg2;
    logic clk2_glitchfree;

    // --------------------------------------------------------
    // MUX Logic
    // --------------------------------------------------------

    always_ff @(posedge clk1 or negedge rst_n) begin
        if (~rst_n) begin
            clk1_en_stg1 <= 1'b0;
            clk1_en_stg2 <= 1'b0;
        end else begin
            clk1_en_stg1 <= (sel == 1'b0) & (clk2_en_stg2 == 1'b0);
            clk1_en_stg2 <= clk1_en_stg1;
        end
    end

    always_ff @(posedge clk2 or negedge rst_n) begin
        if (~rst_n) begin
            clk2_en_stg1 <= 1'b0;
            clk2_en_stg2 <= 1'b1;
        end else begin
            clk2_en_stg1 <= (sel == 1'b1) & (clk1_en_stg2 == 1'b0);
            clk2_en_stg2 <= clk2_en_stg1;
        end
    end

    assign clk1_glitchfree = clk1 & clk1_en_stg2 & ~sel;
    assign clk2_glitchfree = clk2 & clk2_en_stg2 & sel;

    // --------------------------------------------------------
    // Output Assignments
    // --------------------------------------------------------
    assign clkout = clk1_glitchfree | clk2_glitchfree;

endmodule
