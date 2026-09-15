/// --------------------------------------------------------
/// dff_synch.sv
/// Ken The Nugget
/// 2 Flip-Flop CDC Synchronizer
/// --------------------------------------------------------

module dff_synch #(
    parameter WIDTH = 4
) (
    input   logic                   clk,
    input   logic                   rst,
    input   logic [WIDTH:0]     async_in,

    output  logic [WIDTH:0]     sync_out
);
    logic [WIDTH:0] signal_q;
    always_ff @(posedge clk or posedge rst) begin
        if (rst) begin
            signal_q <= 0;
            sync_out <= 0;
        end else begin
            signal_q <= async_in;
            sync_out <= signal_q;
        end
    end
endmodule