/// --------------------------------------------------------
/// reset_synch.sv
/// Ken The Nugget
/// 28/06/2026
/// ASync Reset Synchronizer -- Parametrized for prop times
/// --------------------------------------------------------
module reset_synch #(
	parameter MIN_RST  = 5,  // Min Valid Reset Duration 
	parameter CLK_TIME = 7,  // Clk Tree Prop Time
	parameter RST_TIME = 8,  // Rst Tree Prop Time
) (
	input   logic        clk,
	input   logic        reset,

	output  logic        release_reset_o,
	output  logic        gate_clk_o
);

	localparam TOT_CLK = MIN_RST + CLK_TIME + RST_TIME + 1; // Total Time for Reset routine

	logic [4:0] cnt_q, cnt;
	assign cnt = (|cnt_q) ? (cnt_q - 1) : cnt_q;
	always_ff  @(posedge clk or posedge reset) begin
		if (reset) cnt_q <= TOT_CLK + 1;
		else cnt_q <= cnt;
	end
  
	assign gate_clk_o = (cnt_q < (TOT_CLK - MIN_RST)) & (|cnt_q);
	assign release_reset_o = (cnt_q < RST_TIME);
endmodule
