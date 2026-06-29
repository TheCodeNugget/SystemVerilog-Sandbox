/// --------------------------------------------------------
/// lpc_fifo.sv
/// Ken The Nugget
/// 25/06/2026
/// FIFO With AMBA Q-Channel Functionality
/// --------------------------------------------------------

module lpc_fifo (
    input logic clk,
    input logic rst,

    // Wakeup Interface
    input logic if_wakeup,

    // Write Interface
    input logic wr_valid,
    input logic [7:0] wr_payload,

    // Flush Interface
    input logic wr_done,
    output logic wr_flush,

    // Read Interface
    input logic rd_valid
    output logic [7:0] rd_payload,

    // Q-Channel Interface
    input logic qreq_n,
    output logic qaccept_n,
    output logic qactive
);

    ///------------------------------------
    /// Internal Signals
    ///------------------------------------

    // FIFO Signals
    logic fifo_full;
    logic fifo_empty;

    // Machine States
    typedef enum logic [1:0] {ST_RUN, ST_REQ, ST_STOP, ST_EXIT} qch_state_t;
    logic [1:0] Q_STATE, Q_NEXT;

    // Q-Active Signals
    logic q_active_next, q_active_q;

    // Q-Accept Signals
    logic qaccept_n_next, qaccept_n_q;
    logic qaccept_n_en;

    // FIFO Flush Signals
    logic wr_flush_next, wr_flush_q;



    ///------------------------------------
    /// Submodule Instantiations
    ///------------------------------------
    fifo #(.DEPTH(6), .WIDTH(8)) (
        .clk        (clk),
        .rst        (rst),

        .push       (wr_valid),
        .push_data  (wr_payload),

        .pop        (rd_valid),
        .pop_data   (rd_payload),

        .full       (fifo_full),
        .empty      (fifo_empty)
    )


    ///------------------------------------
    /// State Transition Logic
    ///------------------------------------

    always_comb begin
        case (Q_STATE)
            ST_RUN:  Q_NEXT = (~qreq_n)    ? ST_REQ  : ST_RUN;
            ST_REQ:  Q_NEXT = (~qaccept_n) ? ST_STOP : ST_REQ;
            ST_STOP: Q_NEXT = (qreq_n)     ? ST_EXIT : ST_STOP;
            ST_EXIT: Q_NEXT = (qaccept_n)  ? ST_RUN  : ST_EXIT;
            default: Q_NEXT = ST_RUN;
        endcase
    end

    always_ff @(posedge clk or posedge rst) begin
        if (rst) Q_STATE <= ST_RUN;
        else Q_STATE <= Q_NEXT;
    end

    ///------------------------------------
    /// Q-Active Logic
    ///------------------------------------

    assign q_active_next = ~fifo_empty | wr_valid | rd_valid;
    always_ff @(posedge clk or posedge rst) begin
        if (rst) q_active_q <= 1'b0;
        else q_active_q <= q_active_next;
    end

    ///------------------------------------
    /// Q-Accept_N Logic
    ///------------------------------------

    assign qaccept_n_next = ~((fifo_empty & wr_done) & (~qreq_n));
    assign qaccept_n_en = (Q_STATE == ST_EXIT) | (Q_STATE == ST_REQ);

    always_ff @(posedge clk or posedge rst) begin
        if (rst) qaccept_n_q <= 1'b1;
        else if (qaccept_n_en) qaccept_n_q <= qaccept_n_next;
    end

    ///------------------------------------
    /// FIFO Flush Logic
    ///------------------------------------
    assign wr_flush_next = ((Q_STATE == ST_REQ) | wr_flush_q) & ~(wr_done);

    always_ff @(posedge clk or posedge rst) begin
        if (rst) wr_flush_q <= 1'b0;
        else wr_flush_q <= wr_flush_next;
    end

    ///------------------------------------
    /// Output assignments
    ///------------------------------------

    assign qactive = q_active_q;
    assign qaccept_n = qaccept_n_q;
    assign wr_flush = wr_flush_q;
    
endmodule
