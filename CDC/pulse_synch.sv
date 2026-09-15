/// --------------------------------------------------------
/// pulse_synch.sv
/// Ken The Nugget
/// Pulse CDC Synchronizer
/// --------------------------------------------------------

module pulse_synch (
    input   logic           clk_a,
    input   logic           clk_b,
    input   logic           reset_n,
    input   logic           async_in,

    output  logic           busy,
    output  logic           sync_out
);

    logic dff_a0, dff_a1, dff_a2;
    logic dff_b0, dff_b1, dff_b2;
    logic a0_in;

    always_comb begin
        case ({async_in, dff_a2})
            2'b00: a0_in = dff_a0;
            2'b01: a0_in = 1'b0;
            2'b10: a0_in = 1'b1;
            2'b11: a0_in = 1'b1;
        endcase
    end

    always_ff @(posedge clk_a or negedge reset_n) begin
        if (~reset_n) begin
            dff_a0 <= 1'b0;
            dff_a1 <= 1'b0;
            dff_a2 <= 1'b0;
        end else begin
            dff_a0 <= a0_in;
            dff_a1 <= dff_b1;
            dff_a2 <= dff_a1;
        end
    end

    always_ff @(posedge clk_b or negedge reset_n) begin
        if (~reset_n) begin
            dff_b0 <= 1'b0;
            dff_b1 <= 1'b0;
            dff_b2 <= 1'b0;
        end else begin
            dff_b0 <= dff_a0;
            dff_b1 <= dff_b0;
            dff_b2 <= dff_b2;
        end
    end

    assign busy = dff_a2 | dff_a0;
    assign sync_out = dff_b1 & ~(dff_b2);

endmodule
