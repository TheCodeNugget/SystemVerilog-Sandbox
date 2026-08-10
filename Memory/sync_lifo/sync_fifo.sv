/// --------------------------------------------------------
/// sync_lifo.sv
/// Ken The Nugget
/// Parametrised Synchronous LIFO Memory
/// --------------------------------------------------------

`timescale 1ns/1ns
module sync_lifo #(
    parameter DATA_WIDTH = 8,
    parameter DEPTH = 16
) (
    input   logic                   clk,
    input   logic                   reset_n,
    input   logic                   write_en,
    input   logic                   read_en,
    input   logic [DATA_WIDTH-1:0]  data_in,

    output  logic                   empty,
    output  logic                   full,
    output  logic [DATA_WIDTH-1:0]  data_out
);

    ///------------------------------------
    /// Internal Signals
    ///------------------------------------

    logic [$clog2(DEPTH) - 1:0] addr_ptr;
    logic [DATA_WIDTH-1:0]  data_q;
    logic [DATA_WIDTH-1:0]  lifo_mem [DEPTH-1:0];

    ///------------------------------------
    /// LIFO Logic
    ///------------------------------------

    // Address Pointer Handling
    always_ff @(posedge clk or negedge reset_n) begin
        if (~reset_n) addr_ptr <= '0;
        else begin
            if (write_en & !full) addr_ptr <= addr_ptr + 1;
            if (read_en & !empty) addr_ptr <= addr_ptr - 1;
        end
    end

    // Write Handling
    always_ff @(posedge clk) begin
        if (write_en & !full) lifo_mem[addr_ptr] <= data_in;
    end

    // Read Handling
    always_ff @(posedge clk or negedge reset_n) begin
        if (~reset_n) data_q <= '0;
        else if (read_en & !empty) data_q <= lifo_mem[addr_ptr - 1];
    end

    ///------------------------------------
    /// Output Assignments
    ///------------------------------------

    assign empty = addr_ptr == 0;
    assign full = addr_ptr == 4'(DEPTH - 1);
    assign data_out = data_q;

endmodule
