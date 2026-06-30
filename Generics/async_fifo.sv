module async_fifo #(
    parameter  DATA_WIDTH = 8,
    parameter  DEPTH = 16
) (
    input logic w_clk,
    input logic w_rst,
    input logic w_inc,
    input logic [DATA_WIDTH-1:0] w_data,
    
    input logic r_clk,
    input logic r_rst,
    input logic r_inc,

    output logic w_full,
    output logic r_empty,
    output logic [DATA_WIDTH-1:0] r_data
);
    ///------------------------------------
    /// Internal Signals
    ///------------------------------------
    localparam PTR_WIDTH = $clog2(DEPTH);

    logic [PTR_WIDTH:0] r_ptr_bin, r_ptr_gray, r_ptr_gray_sync;
    logic [PTR_WIDTH:0] w_ptr_bin, w_ptr_gray, w_ptr_gray_sync;


    ///------------------------------------
    /// Fifo Logic
    ///------------------------------------
    logic [DATA_WIDTH-1:0] fifo_mem [DEPTH-1:0];
    always_ff @(posedge w_clk) begin
        if (w_inc & !w_full) fifo_mem[w_ptr_bin[PTR_WIDTH-1:0]] <= w_data;
    end

    always_ff @(posedge r_clk) begin
        if (r_inc & !r_empty) r_data <= fifo_mem[r_ptr_bin[PTR_WIDTH-1:0]];
    end


    ///------------------------------------
    /// Submodule Instantiations
    ///------------------------------------
    w_ptr_handler #(.PTR_WIDTH(PTR_WIDTH)) w_ptr_handler (
        .clk        (w_clk),
        .rst        (w_rst),
        .en         (w_inc),
        .r_ptr_gray (r_ptr_gray_sync),

        .full       (w_full),
        .w_ptr_bin  (w_ptr_bin),
        .w_ptr_gray (w_ptr_gray)
    );

    ptr_cdc_synch #(.PTR_WIDTH(PTR_WIDTH)) w_ptr_cdc (
        .clk        (w_clk),
        .rst        (w_rst),
        .async_in   (r_ptr_gray),
        .sync_out   (r_ptr_gray_sync)
    );

    r_ptr_handler #(.PTR_WIDTH(PTR_WIDTH)) r_ptr_handler (
        .clk        (r_clk),
        .rst        (r_rst),
        .en         (r_inc),
        .w_ptr_gray (w_ptr_gray_sync),

        .empty      (r_empty),
        .r_ptr_bin  (r_ptr_bin),
        .r_ptr_gray (r_ptr_gray)
    );

    ptr_cdc_synch #(.PTR_WIDTH(PTR_WIDTH)) r_ptr_cdc (
        .clk        (w_clk),
        .rst        (w_rst),
        .async_in   (w_ptr_gray),
        .sync_out   (w_ptr_gray_sync)
    );

endmodule

module w_ptr_handler #(
    parameter  PTR_WIDTH = 4
) (
    input logic clk,
    input logic rst,
    input logic en,
    input logic [PTR_WIDTH:0] r_ptr_gray,

    output logic full,
    output logic [PTR_WIDTH:0] w_ptr_bin,
    output logic [PTR_WIDTH:0] w_ptr_gray
);

    ///------------------------------------
    /// Pointer Counter
    ///------------------------------------
    always_ff @(posedge clk or posedge rst) begin
        if (rst) w_ptr_bin <= 0;
        else w_ptr_bin <= w_ptr_bin + (en & !full);
    end

    ///------------------------------------
    /// Output Assignments
    ///------------------------------------
    assign w_ptr_gray = (w_ptr_bin >> 1) ^ w_ptr_bin;
    assign full = (w_ptr_gray == {~r_ptr_gray[PTR_WIDTH:PTR_WIDTH-1], r_ptr_gray[PTR_WIDTH-2:0]});
endmodule

module r_ptr_handler #(
    parameter  PTR_WIDTH = 4
) (
    input logic clk,
    input logic rst,
    input logic en,
    input logic [PTR_WIDTH:0] w_ptr_gray,

    output logic empty,
    output logic [PTR_WIDTH:0] r_ptr_bin,
    output logic [PTR_WIDTH:0] r_ptr_gray
);
    logic [PTR_WIDTH:0] r_ptr_bin_next;
    ///------------------------------------
    /// Pointer Counter
    ///------------------------------------
    always_ff @(posedge clk or posedge rst) begin
        if (rst) r_ptr_bin <= 0;
        else r_ptr_bin <= r_ptr_bin + (en & !empty);
    end

    ///------------------------------------
    /// Output Assignments
    ///------------------------------------
    
    assign r_ptr_gray = (r_ptr_bin >> 1) ^ r_ptr_bin;
    assign empty = w_ptr_gray == r_ptr_gray;
endmodule

module ptr_cdc_synch #(
    parameter PTR_WIDTH = 4
) (
    input logic clk,
    input logic rst,
    input logic [PTR_WIDTH:0] async_in,

    output logic [PTR_WIDTH:0] sync_out
);
    logic [PTR_WIDTH:0] signal_q;
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