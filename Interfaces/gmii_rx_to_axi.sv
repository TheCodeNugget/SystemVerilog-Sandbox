/// --------------------------------------------------------
/// gmii_rx_to_axi.sv
/// Ken The Nugget
/// GMII to AXI Stream Interface
/// --------------------------------------------------------

module gmii_rx_to_axi (
    // GMII Interface
    input   logic           gmii_rx_clk,
    input   logic [7:0]     gmii_rxd,
    input   logic           gmii_rx_dv,

    // AXI Interface
    input   logic           m_axis_tready,
    output  logic [7:0]     m_axis_tdata,
    output  logic           m_axis_tvalid,
    output  logic           m_axis_tlast         
);

    ///------------------------------------
    /// Internal Signals
    ///------------------------------------
    logic [1:0] STATE, NEXT;
    typedef enum logic [1:0] {IDLE, RCVD, DONE} gmii_state_t;

    ///------------------------------------
    /// State Transition Logic
    ///------------------------------------
    always_comb begin
        case (STATE)
            IDLE:    NEXT = (gmii_rx_dv)     ? RCVD : IDLE;
            RCVD:    NEXT = (gmii_rx_dv)     ? RCVD : DONE;
            DONE:    NEXT = (m_axis_tready)  ? IDLE : DONE;
            default: NEXT = IDLE;
        endcase
    end

    always_ff @(posedge gmii_rx_clk) begin
        STATE <= NEXT;
    end

    ///------------------------------------
    /// Execution Logic
    ///------------------------------------
    always_ff @(posedge gmii_rx_clk) begin
        case (STATE)
            IDLE: begin
                m_axis_tlast <= 1'b0;
            end

            RCVD: begin
                if (gmii_rx_dv) m_axis_tdata <= gmii_rxd;
            end

            DONE: begin
                if (gmii_rx_dv) m_axis_tdata <= gmii_rxd;
                m_axis_tlast <= 1'b1;
            end

            default: begin
                m_axis_tlast <= 1'b0;
            end
        endcase
    end

    ///------------------------------------
    /// Output Assignments
    ///------------------------------------
    assign m_axis_tvalid = (STATE != IDLE) & (m_axis_tready);

endmodule
