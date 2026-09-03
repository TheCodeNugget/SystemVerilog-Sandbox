/// --------------------------------------------------------
/// byte_enable_ram.sv
/// Ken The Nugget
/// Parametrizable Dual Port Byte Enable Ram With Collision Handling
/// --------------------------------------------------------

`timescale 1ns/1ns
module byte_enable_ram #(
    parameter XLEN  = 32,
    parameter LINES = 8192,
    localparam ADDR_WIDTH = $clog2(LINES),
    localparam BYTE_WIDTH = XLEN/8
) (
    input   logic                       clk,
    input   logic                       reset_n,

    // Port-A Interface
    input   logic [ADDR_WIDTH-1:0]      addr_a,
    input   logic                       en_a,
    input   logic [BYTE_WIDTH-1:0]      be_a,
    input   logic [XLEN-1:0]            data_in_a,
    output  logic [XLEN-1:0]            data_out_a,

    // Port-B Interface
    input   logic [ADDR_WIDTH-1:0]      addr_b,
    input   logic                       en_b,
    input   logic [BYTE_WIDTH-1:0]      be_b,
    input   logic [XLEN-1:0]            data_in_b,
    output  logic [XLEN-1:0]            data_out_b
);

    logic [XLEN-1:0] ram [LINES-1:0];

    // Reset Logic
    generate
        for (genvar i = 0; i < LINES; i++) begin
            always_ff @(posedge clk or negedge reset_n) begin
                if (~reset_n) ram[i] = '0;
            end
        end
    endgenerate

    // Read Logic
    always_ff @(posedge clk) begin
        data_out_a <= ram[addr_a];
        data_out_b <= ram[addr_b];
    end

    generate
        for (genvar i = 0; i < BYTE_WIDTH; i++) begin
            always_ff @(posedge clk) begin
                if ((addr_a == addr_b) & (en_a & en_b)) begin
                    ram[addr_a][i*8+:8] <= (be_a[i]) ? data_in_a[i*8+:8] : ((be_b[i]) ? data_in_b[i*8+:8] : ram[addr_a][i*8+:8]);
                end else begin
                    if (en_a) ram[addr_a][i*8+:8] <= (be_a[i]) ? data_in_a[i*8+:8] : ram[addr_a][i*8+:8];
                    if (en_b) ram[addr_b][i*8+:8] <= (be_b[i]) ? data_in_b[i*8+:8] : ram[addr_b][i*8+:8];
                end
            end
        end
    endgenerate

endmodule
