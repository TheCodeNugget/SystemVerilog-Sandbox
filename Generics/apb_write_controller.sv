/// --------------------------------------------------------
/// atomic_counter.sv
/// Ken The Nugget
/// 25/06/2026
/// AMBA APB Event Controller - Write Only - ACCESS Timeout
/// --------------------------------------------------------
module apb_write_controller (
    input   logic         clk,
    input   logic         reset_n,

    input   logic         select_a_i,
    input   logic [31:0]  addr_a_i,
    input   logic [31:0]  data_a_i,

    input   logic         select_b_i,
    input   logic [31:0]  addr_b_i,
    input   logic [31:0]  data_b_i,

    input   logic         select_c_i,
    input   logic [31:0]  addr_c_i,
    input   logic [31:0]  data_c_i, 

    output  logic         apb_psel_o,
    output  logic         apb_penable_o,
    output  logic [31:0]  apb_paddr_o,
    output  logic         apb_pwrite_o,
    output  logic [31:0]  apb_pwdata_o,
    input   logic         apb_pready_i
);

    // --------------------------------------------------------
    // Internal Signal List
    // --------------------------------------------------------
    /// State ENUMS and Registers
    typedef enum logic [1:0] {ST_IDLE, ST_SETUP, ST_ACCESS} apb_state_t;
    logic [1:0] state, next_state;

    /// Event Detection Flag
    logic event_detected;

    /// Access State Flags
    logic access_BUSY;
    logic access_timeout;

    /// Access Timeout Counter
    logic [3:0] access_tout_cnt;

    /// APB Holding Registers
    logic [31:0] apb_paddr_q, next_paddr;
    logic [31:0] apb_pwdata_q, next_pwdata;


    // --------------------------------------------------------
    // State Transition Logic and FFs
    // --------------------------------------------------------

    always_ff @(posedge clk or negedge reset_n) begin
        if (~reset_n) state <= ST_IDLE;
        else state <= next_state;
    end

    assign event_detected = | {select_a_i, select_b_i, select_c_i};
    assign access_BUSY = ~(access_timeout | apb_pready_i);
    always_comb begin
        case (state)
            ST_IDLE:    next_state = (event_detected) ? ST_SETUP : ST_IDLE; 
            ST_SETUP:   next_state = ST_ACCESS;
            ST_ACCESS:  next_state = (access_BUSY) ? ST_ACCESS : ST_IDLE;
            default:    next_state = ST_IDLE;
        endcase
    end

    // --------------------------------------------------------
    // State Execution Logic
    // --------------------------------------------------------
    always_comb begin
        case (state)
            ST_IDLE: begin
                casez ({select_a_i, select_b_i, select_c_i})
                    3'b1??: begin
                        next_paddr  = addr_a_i;
                        next_pwdata = data_a_i;
                    end
                    3'b01?: begin
                        next_paddr  = addr_b_i;
                        next_pwdata = data_b_i;
                    end
                    3'b001: begin
                        next_paddr  = addr_c_i;
                        next_pwdata = data_c_i;
                    end
                endcase
            end
        endcase
    end

    // --------------------------------------------------------
    // APB Address & Data FFs
    // --------------------------------------------------------
    always_ff @(posedge clk or negedge reset_n) begin
        if (~reset_n) apb_paddr_q <= 32'h0;
        else apb_paddr_q <= next_paddr;
    end
    
    always_ff @(posedge clk or negedge reset_n) begin
        if (~reset_n) 
            apb_pwdata_q <= 32'h0;
        else if (event_detected & (state == ST_IDLE))
            apb_pwdata_q <= next_pwdata;
    end

    // --------------------------------------------------------
    // Access State Timeout Counter
    // --------------------------------------------------------
    assign access_timeout = access_tout_cnt == 4'hf;
    always_ff @(posedge clk or negedge reset_n) begin
        if (~reset_n) access_tout_cnt <= 4'h0;
        else access_tout_cnt <= (state == ST_ACCESS) ? access_tout_cnt + 1 : 4'h0;
    end

    // --------------------------------------------------------
    // Output Assignments
    // --------------------------------------------------------
    assign apb_psel_o     = (state == ST_ACCESS) | (state == ST_SETUP);
    assign apb_penable_o  = (state == ST_ACCESS);
    assign apb_pwrite_o   = 1'b1;
    assign apb_paddr_o    = apb_paddr_q;
    assign apb_pwdata_o   = apb_pwdata_q;
endmodule