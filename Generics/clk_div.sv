/// --------------------------------------------------------
/// Clock Divider - RTL
/// Ken The Nugget
/// 25/06/2026
/// --------------------------------------------------------

module clk_div #(
    parameter N = 4
) (
    input   logic clk_in,
    input   logic rst_n,
    output  logic clk_out
);
    
    logic [$clog2(N)-1:0] counter;
    always_ff @(posedge clk_in or negedge rst_n) begin
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

module clk_tick #(
    parameter MODULO = 6000000
) (
    input   logic   clk,
    input   logic   reset_n,

    output  logic   tick
);

    localparam WIDTH = (MODULO == 1) ? 1 : $clog2(MODULO);

    logic [WIDTH-1:0] count;

    always_ff @(posedge clk or negedge reset_n) begin
        if (~reset_n) count <= '0;
        else count <= count + 1;
    end

    assign tick = (count == (MODULO - 1));

endmodule
