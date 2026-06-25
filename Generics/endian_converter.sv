/// --------------------------------------------------------
/// Endian Converter - RTL
/// Ken The Nugget
/// 25/06/2026
/// --------------------------------------------------------

module endian_converter #(
  parameter DATA_WIDTH = 32
) (
    input   logic [DATA_WIDTH-1:0] data_i,
    output  logic [DATA_WIDTH-1:0] data_o
);
    genvar i;
        generate
            for (i = 0; i < DATA_WIDTH / 8; i++) begin
                assign data_o[(DATA_WIDTH-1)-8*i-:8] = data_i[i*8+:8];
            end
    endgenerate
endmodule