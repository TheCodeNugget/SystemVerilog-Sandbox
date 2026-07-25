/// --------------------------------------------------------
/// debouncer.sv
/// Ken The Nugget
/// 25/06/2026
/// Parametrised Button Debouncing RTL
/// --------------------------------------------------------

module debouncer #(
    parameter CLK_FREQ = 50_000_000,    // Clock frequency in Hz
    parameter DEBOUNCE_TIME_MS = 20     // Debounce time in milliseconds
) (
    input   logic   clk,
    input   logic   reset,
    input   logic   button_in,
    output  logic   button_out
);

    // --------------------------------------------------------
    // Localparams and Typedefs
    // --------------------------------------------------------
    
    localparam COUNTER_MAX = (CLK_FREQ / 1000) * DEBOUNCE_TIME_MS;
    localparam COUNTER_WIDTH = $clog2(COUNTER_MAX);

    // --------------------------------------------------------
    // Internal Signal List
    // --------------------------------------------------------

    logic [COUNTER_WIDTH-1:0] counter;
    logic button_q, button_sync;

    // --------------------------------------------------------
    // Debouncing Logic
    // --------------------------------------------------------

    always_ff @(posedge clk or posedge reset) begin
        if (reset) begin
            button_q <= 1'b0;
            button_sync <= 1'b0;
        end else begin
            button_q <= button_in;
            button_sync <= button_q;
        end
    end

    always_ff @(posedge clk or posedge reset) begin
        if (reset) counter <= 0;
        else if (button_sync) counter <= (counter == COUNTER_MAX-1) ? counter : counter + 1;
        else counter <= '0;
    end

    // --------------------------------------------------------
    // Output Assignments
    // --------------------------------------------------------

    assign button_out = (counter == COUNTER_MAX-1);

endmodule
