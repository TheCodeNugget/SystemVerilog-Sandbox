/// --------------------------------------------------------
/// div_three.sv
/// Ken The Nugget
/// 25/06/2026
/// Detect if a stream of bits is divisible by 3
/// --------------------------------------------------------

module div_three (
    input   logic clk,
    input   logic reset,
    input   logic x_i,
    output  logic div_o

);

  // State Transition Logic
    logic[1:0] state, next;
    localparam REM_0 = 2'b00, REM_1 = 2'b01, REM_2 = 2'b10;
    always_comb begin
        case (state)
            REM_0: next = (x_i) ? REM_1 : REM_0;
            REM_1: next = (x_i) ? REM_0 : REM_2;
            REM_2: next = (x_i) ? REM_2 : REM_1;
            default: next = REM_0;
        endcase
    end
  
  // State FFs
    always_ff @(posedge clk or posedge reset) begin
        if (reset) state <= REM_0;
        else state <= next;
    end
    assign div_o = next == REM_0;
endmodule