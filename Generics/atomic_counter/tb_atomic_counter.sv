`timescale 1ns/1ns

module tb_atomic_counter;

    // --------------------------------------------------------
    // TB to DUT connections
    // --------------------------------------------------------
    logic               clk;
    logic               reset_n;
    logic               trig_i;
    logic               req_i;
    logic               atomic_i;
    logic               ack_o;
    logic[31:0]         count_o;


    // --------------------------------------------------------
    // Instantiate DUT
    // --------------------------------------------------------
    atomic_counter DUT(
        .clk                (clk),
        .reset_n            (reset_n),
        .trig_i             (trig_i),
        .req_i              (req_i),
        .atomic_i           (atomic_i),
        .ack_o              (ack_o),
        .count_o            (count_o)
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
        trig_i      = 1'b0;
        req_i       = 1'b0;
        atomic_i    = 1'b0;
        repeat (3) @(posedge clk);
        reset_n = 1'b1;
    endtask

    task check_counting_behavior();
        $display("[INFO] @ %0t: Testing Internal Counter", $time);
        delay = {$random} % 32;
        trig_i = 1'b1;
        repeat (delay) @(posedge clk);
        req_i    = 1'b1;
        atomic_i = 1'b1;
        $display("[INFO] @ %0t: Counted %d Cycles Checking Register", $time, delay);
        @(posedge clk);
        if ((ack_o == 1'b1) & (count_o == (delay + 1))) begin
            $display("[PASS] @ %0t: Counter Behaviour OK!", $time);
        end else begin
            $error("[FAIL] @ %0t: Counter Error Expected: 0x%h GOT: 0x%h", $time, delay, count_o);
        end
    endtask

    task check_atomic_behaviour();
        $display("[INFO] @ %0t: Testing Atomic Behaviour", $time);
        trig_i = 1'b1;
        repeat (5) @(posedge clk);
        $display("[INFO] @ %0t: Request Atomic Count", $time);
        req_i    = 1'b1;
        atomic_i = 1'b1;
        @(posedge clk);
        req_i    = 1'b0;
        atomic_i = 1'b0;
        @(posedge clk);
        $display("[PASS] @ %0t: Waiting For Timer to Roll Over bit 33", $time);
        #45000ns;
        $display("[PASS] @ %0t: Requesting Atomic Count", $time);
        req_i    = 1'b1;
        @(posedge clk);
        if ((count_o == 0)) begin
            $display("[PASS] @ %0t: Atomic Behaviour OK!", $time);
        end else begin
            $error("[FAIL] @ %0t: Counter Error Expected: 0 GOT: 0x%h", $time, count_o);
        end
    endtask

    // --------------------------------------------------------
    // TestBench Internal Variables
    // --------------------------------------------------------
    int delay;

    // --------------------------------------------------------
    // TestBench Logic
    // --------------------------------------------------------
    initial begin
        reset_device();
        check_counting_behavior();
        reset_device();
        check_atomic_behaviour();
        $finish;
    end

endmodule
