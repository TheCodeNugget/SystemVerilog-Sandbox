/// --------------------------------------------------------
/// bcd_clock.sv
/// Ken The Nugget
/// 30/06/2026
/// 24Hr Clock using BCD Counters
/// --------------------------------------------------------
module bcd_clock (
    input logic clk,
    input logic rst,

    output logic [3:0] ms_hr,
    output logic [3:0] ls_hr,

    output logic [3:0] ms_min,
    output logic [3:0] ls_min,

    output logic [3:0] ms_sec,
    output logic [3:0] ls_sec
);

    logic sec_rst, min_rst, hr_rst;
    logic lssec_en, mssec_en, lsmin_en, msmin_en, lshr_en, mshr_en;

    assign sec_rst = ((ms_sec == 4'h5) & (ls_sec == 4'h9)) || rst;
    assign lssec_en = 1'b1;
    counter lssec (
        .clk    (clk),
        .en     (clk),
        .rst    (sec_rst),
        .q      (ls_sec)
    );

    assign mssec_en = (ls_sec == 4'h9);
    counter mssec (
        .clk    (clk),
        .en     (mssec_en),
        .rst    (sec_rst),
        .q      (ms_sec)
    );

    assign min_rst = ((ms_min == 4'h5) & (ls_min == 4'h9) & sec_rst) || rst;
    assign lsmin_en = ((ms_sec == 4'h5) & mssec_en);
    counter lsmin (
        .clk    (clk),
        .en     (lsmin_en),
        .rst    (min_rst),
        .q      (ls_min)
    );

    assign msmin_en = (ls_min == 4'h9) & lsmin_en;
    counter msmin (
        .clk    (clk),
        .en     (msmin_en),
        .rst    (min_rst),
        .q      (ms_min)
    );

    assign hr_rst = ((ms_hr == 4'h2) & (ls_hr == 4'h3) & min_rst) || rst; 
    assign lshr_en = ((ms_min == 4'h5) & msmin_en);
    counter lshr (
        .clk    (clk),
        .en     (lshr_en),
        .rst    (hr_rst),
        .q      (ls_hr)
    );

    assign mshr_en = (ls_hr == 9) & lshr_en;
    counter mshr (
        .clk    (clk),
        .en     (mshr_en),
        .rst    (hr_rst),
        .q      (ms_hr)
    );

endmodule

module counter(input clk, input en, input rst, output reg [3:0] q);
    always_ff @(posedge clk) begin
        if (rst) q <= 4'd0;
        else if (en) q <= (q == 4'h9) ? 4'h0 : q + 4'h1;
    end
endmodule
