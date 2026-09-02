/// --------------------------------------------------------
/// galois_lsfr.sv
/// Ken The Nugget
/// Parametrised Galois LFSR
/// --------------------------------------------------------
`timescale 1ns/1ns

module galois_lfsr #(
    parameter WIDTH = 16,
    parameter TAPS  = 16'h00AA,
    parameter SEED  = 16'hFFFF
) (
    input   logic               clk,
    input   logic               reset_n,
    input   logic               en,
    output  logic [WIDTH-1:0]   lfsr_out
);

    logic [WIDTH-1:0] lfsr_next;

    assign lfsr_next[WIDTH-1] = lfsr_out[0];
    generate
        for (genvar i = WIDTH-2; i >= 0; i--) begin
            if (TAPS[i]) assign lfsr_next[i] = lfsr_out[i+1] ^ lfsr_out[0];
            else assign lfsr_next[i] = lfsr_out[i+1];
        end
    endgenerate

    always_ff @(posedge clk or negedge reset_n ) begin
        if (~reset_n) lfsr_out <= SEED;
        else lfsr_out <= lfsr_next;
    end

endmodule
