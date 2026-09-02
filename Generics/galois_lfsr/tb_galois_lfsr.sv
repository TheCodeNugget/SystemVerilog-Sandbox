`timescale 1ns/1ns

module tb_galois_lfsr;
    logic           clk;
    logic           reset_n;
    logic           en;
    logic [15:0]    lfsr_out;

    galois_lfsr #(
        .TAPS(16'h0A00),
        .SEED(16'hFF00)
    ) DUT (
        .clk        (clk),
        .reset_n    (reset_n),
        .en         (en),
        .lfsr_out   (lfsr_out)
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

    // --------------------------------------------------------
    // TestBench Functions
    // --------------------------------------------------------
    task reset_device();
        $display("[INFO] @ %0t: Resetting DUT", $time);
        reset_n     = 1'b0;
        repeat (3) @(posedge clk);
        reset_n = 1'b1;
    endtask


    // --------------------------------------------------------
    // TestBench Logic
    // --------------------------------------------------------
    initial begin
        reset_device();
        repeat (40) @(posedge clk);
        $finish;
    end

endmodule
