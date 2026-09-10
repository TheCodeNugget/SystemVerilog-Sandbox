/// --------------------------------------------------------
/// vga_controller.sv
/// Ken The Nugget
/// 640x480 VGA Controller
/// --------------------------------------------------------

module vga_controller (
    input   logic           clk,
    input   logic           reset_n,
    input   logic [7:0]     colour_in,
    
    output  logic [7:0]     red,
    output  logic [7:0]     green,
    output  logic [7:0]     blue,

    output  logic [9:0]     next_x,
    output  logic [9:0]     next_y,

    output  logic           vga_hsync,
    output  logic           vga_vsync,
    output  logic           vga_sync,
    output  logic           vga_clock,
    output  logic           vga_blank
);

    ///------------------------------------
    /// Local Parameters
    ///------------------------------------

    // Horizontal Lines
    localparam H_ACTIVE_LINES = 640;
    localparam H_FRONT_LINES  = 16;
    localparam H_PULSE_LINES  = 96;
    localparam H_BACK_LINES   = 48;

    // Vertical Lines
    localparam V_ACTIVE_LINES = 480;
    localparam V_FRONT_LINES  = 10;
    localparam V_PULSE_LINES  = 2;
    localparam V_BACK_LINES   = 33;

    ///------------------------------------
    /// Internal Signals
    ///------------------------------------
    logic [9:0] h_counter;
    logic [9:0] v_counter;
    logic line_done;

    ///------------------------------------
    /// H-Sync State Machine
    ///------------------------------------
    typedef enum logic [1:0] {H_ACTIVE, H_FRONT, H_PULSE, H_BACK} hsync_state_t;
    logic [1:0] H_STATE;

    always_ff @(posedge clk or negedge reset_n) begin
        if (~reset_n) begin
            h_counter   <= '0;
            H_STATE     <= H_ACTIVE;
            line_done   <= 1'b0;
        end else begin
            case (H_STATE)
                H_ACTIVE: begin
                    if (h_counter == H_ACTIVE_LINES - 1) begin
                        vga_hsync   <= 1'b1;
                        H_STATE     <= H_PULSE;
                        h_counter   <= '0;
                    end else begin
                        line_done   <= 1'b0;
                        h_counter   <= h_counter + 1;
                    end
                end
                H_FRONT: begin
                    if (h_counter == H_FRONT_LINES - 1) begin
                        vga_hsync   <= 1'b1;
                        H_STATE     <= H_PULSE;
                        h_counter   <= '0;
                    end else begin
                       h_counter    <= h_counter + 1; 
                    end
                end
                H_PULSE: begin
                    if (h_counter == H_PULSE_LINES - 1) begin
                        H_STATE     <= H_BACK;
                        h_counter   <= '0;
                    end else begin
                        h_counter   <= h_counter + 1;
                        vga_hsync   <= 1'b0;
                    end
                end
                H_BACK: begin
                    if (h_counter == H_BACK_LINES - 1) begin
                        H_STATE     <= H_ACTIVE;
                        h_counter   <= '0;
                        line_done   <= 1'b1;
                    end else begin
                        h_counter   <= h_counter + 1;
                        vga_hsync   <= 1'b1;
                    end
                end
            endcase
        end
    end

    ///------------------------------------
    /// V-Sync State Machine
    ///------------------------------------
    typedef enum logic [1:0] {V_ACTIVE, V_FRONT, V_PULSE, V_BACK} vsync_state_t;
    logic [1:0] V_STATE;

    always_ff @(posedge clk or negedge reset_n) begin
        if (~reset_n) begin
            v_counter   <= '0;
            V_STATE     <= V_ACTIVE;
        end else begin
            case (V_STATE)
                V_ACTIVE: begin
                    if (v_counter == V_ACTIVE_LINES - 1) begin
                        vga_vsync   <= 1'b1;
                        V_STATE     <= V_PULSE;
                        v_counter   <= '0;
                    end else begin
                        v_counter <= (line_done) ? v_counter + 1 : v_counter;
                    end
                end
                V_FRONT: begin
                    if (v_counter == V_FRONT_LINES - 1) begin
                        vga_vsync   <= 1'b1;
                        V_STATE     <= V_PULSE;
                        v_counter   <= '0;
                    end else begin
                       v_counter <= (line_done) ? v_counter + 1 : v_counter;
                    end
                end
                V_PULSE: begin
                    if (v_counter == V_PULSE_LINES - 1) begin
                        V_STATE     <= V_BACK;
                        v_counter   <= '0;
                    end else begin
                        v_counter <= (line_done) ? v_counter + 1 : v_counter;
                        vga_vsync   <= 1'b0;
                    end
                end
                V_BACK: begin
                    if (v_counter == V_BACK_LINES - 1) begin
                        V_STATE     <= V_ACTIVE;
                        v_counter   <= '0;
                    end else begin
                        v_counter <= (line_done) ? v_counter + 1 : v_counter;
                        vga_vsync   <= 1'b1;
                    end
                end
            endcase
        end
    end
    
    ///------------------------------------
    /// Output Assignments
    ///------------------------------------
    assign vga_clock    = clk;
    assign vga_sync     = 1'b0;
    assign vga_blank    = (vga_hsync & vga_vsync);

    assign next_x       = (H_STATE == H_ACTIVE) ? h_counter : '0;
    assign next_y       = (V_STATE == V_ACTIVE) ? v_counter : '0;

endmodule
