/// --------------------------------------------------------
/// Palindrome.sv
/// Ken The Nugget
/// 25/06/2026
/// Detecting 3-bit palindrome in a bit stream
/// --------------------------------------------------------

module palindrome (
	input   logic	clk,
	input   logic	reset,
	input   logic	x_i,
	output  logic	palindrome_o
);  
    logic [1:0] state, next;
    always_comb begin
        case (state)
            2'b00: 	 next = 2'b01;
            2'b01: 	 next = 2'b10;
            2'b10: 	 next = 2'b10;
            default: next = 2'b00;
        endcase
    end
  
  	always_ff @(posedge clk or posedge reset)
    	if (reset) state <= 2'b00;
  		else state <= next;
  
  	logic [1:0] buffer;
  	always_ff @(posedge clk or posedge reset)
    	if (reset)
      		buffer <= 2'b00;
    	else
      		buffer <= {buffer[0], x_i}; // Capture the bits 2 & 1 of the palindrome
  	assign palindrome_o = (buffer[1] == x_i) & (state == 2'b10); //only the MSB and LSB Matters for palindrome
endmodule