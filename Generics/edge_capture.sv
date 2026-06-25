/// --------------------------------------------------------
/// Dual Edge Capture - RTL
/// Ken The Nugget
/// 25/06/2026
/// --------------------------------------------------------

module edge_capture (
  	input   logic        clk,
 	input   logic        reset,
  	input   logic [31:0] data_i,

  	output  logic [31:0] posedge_o
  	output  logic [31:0] negedge_o
);
	logic [31:0] data_q;
  	logic [31:0] posedge_q;
  	logic [31:0] negedge_q;
  	always_ff @(posedge clk or posedge reset) begin
    	if (reset) begin
			data_q <= 32'h0;
			posedge_q <= 32'h0;
			negedge_q <= 32'h0;
    	end else begin
			data_q <= data_i; // Record Previous Input
			posedge_q <= posedge_o; // Latch Detected Positive Edges
			negedge_q <= negedge_o; // Latch Detected Negative Edges
    	end
  	end
  	assign posedge_o = (data_i & ~data_q) | posedge_q;
  	assign negedge_o = (~data_i & data_q) | negedge_q;
endmodule
