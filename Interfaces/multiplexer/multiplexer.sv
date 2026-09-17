/// --------------------------------------------------------
/// multiplexer.sv
/// Ken The Nugget
/// Parametrizable Multiplexer with Out-of-Range Handling
/// --------------------------------------------------------

`timescale 1ns/1ps
module multiplexer #( 
    parameter DATA_WIDTH = 8,
    parameter NUM_INPUTS = 4,
    parameter REGISTER_OUTPUT = 0,
    parameter HAS_DEFAULT = 0,
    parameter [DATA_WIDTH-1:0] DEFAULT_VALUE = {DATA_WIDTH{1'b0}}
) (
    input   logic                               clk,
    input   logic                               rst_n,
    input   logic [(DATA_WIDTH*NUM_INPUTS)-1:0] inp,
    input   logic [$clog2(NUM_INPUTS)-1:0]      sel,
    input   logic                               bypass,
    output  logic [DATA_WIDTH-1:0]              out
);

    wire [DATA_WIDTH-1:0] out_comb;

    generate
        for (genvar i = 0; i < NUM_INPUTS; i++) begin
            assign out_comb = (sel == i) ? inp[i*(DATA_WIDTH - 1) +: (DATA_WIDTH)] : 'z;
        end

        if (HAS_DEFAULT) begin
            assign out_comb = (sel >= NUM_INPUTS) ? DEFAULT_VALUE : 'z;
        end

        if (REGISTER_OUTPUT) begin
            always_ff @(posedge clk or negedge rst_n) begin
                if (~rst_n) out <= '0;
                else out <= (bypass) ? inp[DATA_WIDTH-1:0] : out_comb; 
            end
        end else begin
            assign out = (bypass) ? inp[DATA_WIDTH - 1:0] : out_comb;
        end
    endgenerate

endmodule
