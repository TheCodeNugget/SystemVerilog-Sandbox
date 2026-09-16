/// --------------------------------------------------------
/// mux_synch.sv
/// Ken The Nugget
/// Parametrizable MUX CDC Synchronizer
/// --------------------------------------------------------

module mux_synch #(
    parameter WIDTH = 8
) (
    input   logic               clk,
    input   logic               reset_n,
    input   logic               ctrl,
    input   logic [WIDTH-1:0]   async_in,

    output  logic [WIDTH-1:0]   sync_out
);

    logic dff_0, dff_1;
    logic [WIDTH-1:0] dff_out;

    always_ff @(posedge clk or negedge reset_n) begin
        if (~reset_n) begin
            dff_0   <= 1'b0;
            dff_1   <= 1'b0;
            sync_out <= '0;
        end else begin
            dff_0   <= ctrl;
            dff_1   <= dff_0;
            sync_out <= (dff_1) ? async_in : sync_out;
        end
    end

endmodule
