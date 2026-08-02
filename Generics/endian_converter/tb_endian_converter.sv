`timescale 1ns/1ns

module tb_endian_converter;
    logic [31:0]    data_i;
    logic [31:0]    data_o;

    endian_converter DUT(
        .data_i (data_i),
        .data_o (data_o)
    );

    initial begin
        $dumpfile("tb_endian_converter.vcd");
        $dumpvars(1, tb_endian_converter);
    end

    initial begin
        repeat (10) begin
            data_i = $random;
            #10ns;
            $display ("data in=0x%h | data out=0x%h", data_i, data_o);
            #10ns;
        end
    end

endmodule
