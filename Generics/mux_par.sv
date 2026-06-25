/// --------------------------------------------------------
/// par_mux.sv
/// Ken The Nugget
/// 25/06/2026
/// Parametrizable Mux
/// --------------------------------------------------------

module par_mux #(
    parameter NUM_PORTS = 32,
    parameter DATA_WIDTH = 64
)(
    input   logic clk,
    input   logic reset,

    input   logic [NUM_PORTS-1:0] one_hot_sel_i,
    input   logic [NUM_PORTS-1:0][DATA_WIDTH-1:0] data_i,
    
    output  logic [DATA_WIDTH-1:0] mux_data_o
);
    // Mux Generation
    wire [DATA_WIDTH-1:0] selected_data;
    generate
        for (genvar i = 0; i < NUM_PORTS; i++) begin
            assign selected_data = one_hot_sel_i[i] ? data_i[i] : {DATA_WIDTH{1'bz}};
        end
    endgenerate
    
    // Output assignments
    assign mux_data_o = (one_hot_sel_i != 0) ? selected_data : {DATA_WIDTH{1'b0}};
endmodule