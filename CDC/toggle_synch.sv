/// --------------------------------------------------------
/// toggle_synch.sv
/// Ken The Nugget
/// Toggle CDC Synchronizer
/// --------------------------------------------------------

module toggle_synch (
    input   logic           clk,
    input   logic           reset_n,
    input   logic           async_in,

    output  logic           sync_out
);

    logic dff_0, dff_1, dff_2;
    always_ff @(posedge clk or negedge reset_n) begin
        if (~reset_n) begin
            dff_0 <= 1'b0;
            dff_1 <= 1'b0;
            dff_2 <= 1'b0;
        end else begin
            dff_0 <= async_in;
            dff_1 <= dff_0;
            dff_2 <= dff_1;
        end
    end

    assign sync_out = ~(dff_1 | dff_2);

endmodule