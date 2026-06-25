/// --------------------------------------------------------
/// Clock Divider - RTL
/// Ken The Nugget
/// 25/06/2026
/// --------------------------------------------------------

module clk_div #(
    parameter N = 4;
) (
    input   logic clk_in,
    input   logic rst_n,
    output  logic clk_out
);
    logic [$clog2(N)-1:0] counter;
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            counter <= 0;
            clk_out <= 0;
        end else begin
            if (counter == (N-1)) begin
                counter <= 0;
                clk_out <= ~clk_out;  // Toggle output clock
            end else begin
                counter <= counter + 1;
            end
        end
    end
endmodule