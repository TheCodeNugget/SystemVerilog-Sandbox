`timescale 1ns/1ps

module tb_multiplexer;

    logic               clk;
    logic               rst_n;
    logic [8*3-1:0]     inp;
    logic [1:0]         sel;
    logic               bypass;
    wire [7:0]          out;
    integer             i, j;
    logic [7:0]         expected;

    // --------------------------------------------------------
    // Instantiate DUT
    // --------------------------------------------------------
    multiplexer #(
        .DATA_WIDTH         (8),
        .NUM_INPUTS         (3),
        .REGISTER_OUTPUT    (1),
        .HAS_DEFAULT        (1),
        .DEFAULT_VALUE      (8'h55)
    ) dut (
        .clk                (clk),
        .rst_n              (rst_n),
        .inp                (inp),
        .sel                (sel),
        .bypass             (bypass),
        .out                (out)
    );

    // --------------------------------------------------------
    // Generate Clock 100MHz
    // --------------------------------------------------------
    initial clk = 1'b0;
    always #5 clk = ~clk;

    // --------------------------------------------------------
    // Declare Output Files
    // --------------------------------------------------------
    initial begin
        $dumpfile("tb.vcd");
        $dumpvars(1, tb);
    end

    /* verilator lint_off WIDTHTRUNC */
    /* verilator lint_off WIDTHEXPAND */
    initial begin
        clk = 0; rst_n = 0; inp = 0; sel = 0; bypass = 0;
        repeat(2) @(posedge clk);
        rst_n = 1;
        repeat(2) @(posedge clk);
        for (i = 0; i < 10; i = i + 1) begin
            inp = {($random() & 8'hFF), ($random() & 8'hFF), ($random() & 8'hFF)};
            for (j = 0; j < 4; j = j + 1) begin
                sel = j[1:0];
                bypass = 0;
                #1;
                if (sel < 3) expected = inp[sel*8 +: 8];
                else         expected = 8'h55;
                @(posedge clk);
                @(posedge clk);
                if (out !== expected)
                    $display("Time=%0t Sel=%0d Bypass=%0b Inp=%0h Expected=%0h Got=%0h", $time, sel, bypass, inp, expected, out);
                else
                    $display("Time=%0t PASSED Sel=%0d Bypass=%0b", $time, sel, bypass);
                bypass = 1;
                #1;
                expected = inp[0 +: 8];
                @(posedge clk);
                @(posedge clk);
                if (out !== expected)
                    $display("Time=%0t Sel=%0d Bypass=%0b Inp=%0h Expected=%0h Got=%0h", $time, sel, bypass, inp, expected, out);
                else
                    $display("Time=%0t PASSED Sel=%0d Bypass=%0b", $time, sel, bypass);
            end
        end
        $finish;
    end

endmodule
