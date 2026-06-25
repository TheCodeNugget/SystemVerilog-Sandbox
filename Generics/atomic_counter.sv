/// --------------------------------------------------------
/// atomic_counter.sv
/// Ken The Nugget
/// 25/06/2026
/// 64-Bit Atomic Counter for 32-Bit Systems
/// --------------------------------------------------------
module atomic_counter (
    input               clk,
    input               reset,
    input               trig_i,
    input               req_i,
    input               atomic_i,
    output logic        ack_o,
    output logic[31:0]  count_o
);
    // Counter
    logic [63:0] count_q;
    logic [63:0] count;
    assign count = count_q + {63'd0, trig_i};
    always_ff @(posedge clk or posedge reset) begin
        if (reset) count_q[63:0] <= 64'h0;
        else count_q[63:0] <= count;
    end
  
  // Atomic Capture Logic
    logic [31:0] counter_buffer;
    always_ff @(posedge clk or posedge reset) begin
        if (reset) begin
            ack_o   <= 0;
            count_o <= 0;
            counter_buffer <= 0;
        end else if (req_i) begin
            ack_o   <= 1;
            counter_buffer <= (atomic_i) ? count[63:32] : counter_buffer;
            count_o <= (atomic_i) ? count[31:0] : counter_buffer;
        end else begin
            ack_o   <= 0;
            count_o <= 0;
        end
    end
endmodule