/// --------------------------------------------------------
/// bit_finder.sv
/// Ken The Nugget
/// 25/06/2026
/// Collection of Modules to find and manipulate bits
/// --------------------------------------------------------

module bf_lowest_0 #(
    parameter NUM_PORTS = 16;
) (
    input   logic [NUM_PORTS-1:0]  req_i,
    output  logic [NUM_PORTS-1:0]  grant_o
);
    assign grant_o = ~req_i & (req_i + 1);
endmodule

module bf_lowest_1 #(
    parameter NUM_PORTS = 16;
) (
    input   logic [NUM_PORTS-1:0]  req_i,
    output  logic [NUM_PORTS-1:0]  grant_o
);
    assign grant_o = req_i & ~(req_i - 1);
endmodule

module bf_0_from_index #(
    parameter NUM_PORTS = 16;
) (
    input   logic [NUM_PORTS-1:0]  req_i,
    input   logic [$clog2(NUM_PORTS)-1:0] index,
    output  logic [NUM_PORTS-1:0]  grant_o
);
    assign grant_o = ~req_i & (req_i + (1 << index));
endmodule

module bf_1_from_index #(
    parameter NUM_PORTS = 16;
) (
    input   logic [NUM_PORTS-1:0]  req_i,
    input   logic [$clog2(NUM_PORTS)-1:0] index,
    output  logic [NUM_PORTS-1:0]  grant_o
);
    assign grant_o = req_i & ~(req_i - (1 << index));
endmodule

module bf_clr_lowest_1 #(
    parameter NUM_PORTS = 16;
) (
    input   logic [NUM_PORTS-1:0]  req_i,
    input   logic [$clog2(NUM_PORTS)-1:0] index,
    output  logic [NUM_PORTS-1:0]  grant_o
);
    assign grant_o = req_i & (req_i - 1);
endmodule

module bf_set_lowest_0 #(
    parameter NUM_PORTS = 16;
) (
    input   logic [NUM_PORTS-1:0]  req_i,
    input   logic [$clog2(NUM_PORTS)-1:0] index,
    output  logic [NUM_PORTS-1:0]  grant_o
);
    assign grant_o = req_i \| (req_i + 1);
endmodule