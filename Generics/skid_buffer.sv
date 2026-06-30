/// --------------------------------------------------------
/// skid_buffer.sv
/// Ken The Nugget
/// 25/06/2026
/// Generic Skid Buffer
/// --------------------------------------------------------
odule skid_buffer (
  input   logic        clk,
  input   logic        reset,

  input   logic        i_valid_i,
  input   logic [7:0]  i_data_i,
  output  logic        i_ready_o,

  input   logic        e_ready_i,
  output  logic        e_valid_o,
  output  logic [7:0]  e_data_o
);

  ///-----------------------------
  /// Internal Signals
  ///-----------------------------
  typedef enum logic {ST_BYPASS, ST_SKID} skid_state_t;
  logic BUF_STATE, BUF_NEXT;
  
  logic [7:0] data_q;
  
  ///-----------------------------
  /// State Transition Logic
  ///-----------------------------
  always_comb begin
    case (BUF_STATE)
      ST_BYPASS: BUF_NEXT = (~e_ready_i && i_valid_i) ? ST_SKID : ST_BYPASS;
      ST_SKID:   BUF_NEXT = (e_ready_i) ? ST_BYPASS : ST_SKID;
    endcase
  end
  
  always_ff @(posedge clk or posedge reset) begin
    if (reset) BUF_STATE <= ST_BYPASS;
    else BUF_STATE <= BUF_NEXT;
  end
  
  ///-----------------------------
  /// State Execution Logic
  ///-----------------------------
  
  always_ff @(posedge clk or posedge reset) begin
    if (reset) data_q <= 0;
    else if (BUF_STATE == ST_BYPASS) data_q <= i_data_i;
  end
  
  ///-----------------------------
  /// Output Assignments
  ///-----------------------------
  assign i_ready_o = (BUF_STATE == ST_BYPASS);
  assign e_valid_o = (BUF_STATE == ST_BYPASS) ? i_valid_i : 1'b1;
  assign e_data_o  = (BUF_STATE == ST_BYPASS) ? i_data_i : data_q;
  
endmodule
