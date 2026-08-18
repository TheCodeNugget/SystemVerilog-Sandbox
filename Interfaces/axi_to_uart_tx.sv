/// --------------------------------------------------------
/// gmii_rx_to_axi.sv
/// Ken The Nugget
/// AXI Stream to UART uart_tx Interface
/// --------------------------------------------------------

module axis_to_uart_uart_tx #(
    parameter CLK_FREQ = 100,       // UART Clock Frequency in MHz
    parameter BIT_RATE = 115200,    // UART Baud Rate
    parameter BIT_PER_WORD = 8,     // AXI Word Length
    parameter PARITY_BIT = 0,       // Parity Bit Setting 0/1/2 => NoP/Odd/Even
    parameter STOP_BITS_NUM = 1     // UART Stop Bit Setting 1/2
) (
    input   logic                       clk,
    input   logic                       reset_n,

    // AXI Interface
    input   logic [BIT_PER_WORD-1:0]    axi_tdata,
    input   logic                       axi_tvalid,
    output  logic                       axi_tready,

    // UART Interface
    output  logic                       uart_tx
);

    ///------------------------------------
    /// Internal Signals
    ///------------------------------------
    // UART
    localparam UART_PERIOD = (CLK_FREQ * 1000000) / BIT_RATE;
    logic [$clog2(UART_PERIOD)-1:0] uart_clk_cnt;
    logic uart_clk_en;
    logic uart_ping;

    // FSM
    typedef enum logic [3:0] {IDLE, START, DATA, PARITY, STOP1, STOP2} intfc_state_t;
    logic [3:0] STATE, NEXT;

    // FSM Flags
    logic start_done;
    logic uart_tx_done;
    logic parity_done;
    logic stop1_done;
    logic stop2_done;   

    // AXI Data Register
    logic [BIT_PER_WORD-1:0] rx_data;
    logic [$clog2(BIT_PER_WORD)-1:0] rx_data_idx;

    // UART Parity
    logic parity_odd;
    logic parity_even;

    ///------------------------------------
    /// UART Clocking
    ///------------------------------------
    always_ff @(posedge clk or negedge reset_n) begin
        if (~reset_n) begin
            uart_clk_cnt    <= '0;
            uart_ping        <= 1'b0;
        end else begin
            if (uart_clk_en) begin
                if (uart_clk_cnt == (UART_PERIOD - 1)) begin
                    uart_clk_cnt    <= '0;
                    uart_ping        <= 1'b1;
                end else begin
                    uart_ping        <= 1'b0;
                    uart_clk_cnt    <= uart_clk_cnt + 1;
                end
            end
        end
    end

    ///------------------------------------
    /// State Transition Logic
    ///------------------------------------    
    always_comb begin
        case (STATE)
            IDLE:   NEXT = (axi_tvalid) ? START : IDLE;
            START:  NEXT = (start_done) ? DATA : START;
            DATA: begin
                if (uart_tx_done) NEXT = (PARITY_BIT != 0) ? PARITY : STOP1;
                else NEXT = DATA;
            end
            PARITY: NEXT = (parity_done) ? STOP1 : PARITY;
            STOP1: begin
                if (stop1_done) NEXT = (STOP_BITS_NUM == 2) ? STOP2 : IDLE;
                else NEXT = STOP1;
            end
            STOP2:  NEXT = (stop2_done) ? IDLE : STOP2;
            default: NEXT = IDLE;
        endcase
    end

    always_ff @(posedge clk or negedge reset_n) begin
        if (~reset_n) STATE <= IDLE;
        else STATE <= NEXT;
    end

    
    ///------------------------------------
    /// State Execution Logic
    ///------------------------------------
    assign parity_even  =   ^rx_data;
    assign parity_odd   =   ~(^rx_data);
    always_ff @(posedge clk or negedge reset_n) begin
        case (STATE)
            IDLE: begin
                axi_tready      <= 1'b1;
                uart_tx         <= 1'b1;
                start_done      <= 1'b0;
                uart_tx_done    <= 1'b0;
                parity_done     <= 1'b0;
                stop1_done      <= 1'b0;
                stop2_done      <= 1'b0;
                rx_data_idx     <= '0;
                uart_clk_en     <= 1'b0;
            end

            START: begin
                axi_tready  <= 1'b0;
                uart_tx     <= 1'b0;
                uart_clk_en <= 1'b1;
                rx_data     <= axi_tdata;
                if (uart_ping) start_done <= 1'b1;
            end

            DATA: begin
                uart_tx <= rx_data[rx_data_idx];
                if (uart_ping) rx_data_idx <= rx_data_idx + 1'b1;
                if (rx_data_idx == (BIT_PER_WORD - 1)) uart_tx_done <= 1'b1;
            end

            PARITY: begin
                case (PARITY_BIT)
                    0: uart_tx <= 1'b0;
                    1: uart_tx <= parity_odd;
                    2: uart_tx <= parity_even;
                endcase
                if (uart_ping) parity_done <= 1'b1;
            end

            STOP1: begin
                uart_tx <= 1'b1;
                if (uart_ping) stop1_done <= 1'b1;
            end

            STOP2: begin
                uart_tx <= 1'b1;
                if (uart_ping) stop2_done <= 1'b1;
            end

            default: begin
                axi_tready  <= 1'b0;
                uart_tx     <= 1'b1;
            end
        endcase
    end

endmodule
