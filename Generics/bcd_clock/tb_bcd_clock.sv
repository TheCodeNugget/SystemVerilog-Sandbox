`timescale 1ns/1ns

module tb_bcd_clock;
    logic           clk;
    logic           rst;

    logic [3:0]     ms_hr;
    logic [3:0]     ls_hr;
    
    logic [3:0]     ms_min;
    logic [3:0]     ls_min;

    logic [3:0]     ms_sec;
    logic [3:0]     ls_sec;

    bcd_clock DUT (
        .clk            (clk),
        .rst            (rst),

        .ms_hr          (ms_hr),
        .ls_hr          (ls_hr),

        .ms_min         (ms_min),
        .ls_min         (ls_min),

        .ms_sec         (ms_sec),
        .ls_sec         (ls_sec)
    );

    initial clk = 1'b0;
    always #5 clk = ~clk;

    initial begin
        $dumpfile("tb_bcd_clock.vcd");
        $dumpvars(1, tb_bcd_clock);
    end

    logic [23:0]    clock_combined;
    assign  clock_combined = {ms_hr, ls_hr, ms_min, ls_min, ms_sec, ls_sec};

    initial begin
        // Check Reset Behaviour
        $display("[INFO] @ %0t: Testing Reset Behaviour", $time);
        rst = 1'b1;
        repeat (3) @(posedge clk);
        if (clock_combined != 24'h0) $fatal(1, "[FATAL] @ %0t: Reset Behaviour Incorrect!", $time);
        $display("[INFO] @ %0t: Reset Behaviour OK!", $time);
        rst = 1'b0;
        @(posedge clk);

        // Testing Rollovers
        repeat (10) @(posedge clk);
        $display("[INFO] @ %0t: Testing 1's Rollover", $time);
        if (clock_combined != 24'h10) $fatal(1, "[FATAL] @ %0t: 1's Rollover Behaviour Incorrect!", $time);
        $display("[INFO] @ %0t: 1's Rollover Behaviour OK!", $time);

        repeat (50) @(posedge clk);
        $display("[INFO] @ %0t: Testing 10's Rollover", $time);
        if (clock_combined != 24'h100) $fatal(1, "[FATAL] @ %0t: 10's Rollover Behaviour Incorrect!", $time);
        $display("[INFO] @ %0t: 10's Rollover Behaviour OK!", $time);

        repeat (540) @(posedge clk);
        $display("[INFO] @ %0t: Testing 1'm Rollover", $time);
        if (clock_combined != 24'h1000) $fatal(1, "[FATAL] @ %0t: 1'm Rollover Behaviour Incorrect!", $time);
        $display("[INFO] @ %0t: 1'm Rollover Behaviour OK!", $time);

        repeat (3000) @(posedge clk);
        $display("[INFO] @ %0t: Testing 10'm Rollover", $time);
        if (clock_combined != 24'h10000) $fatal(1, "[FATAL] @ %0t: 10'm Rollover Behaviour Incorrect!", $time);
        $display("[INFO] @ %0t: 10'm Rollover Behaviour OK!", $time);

        repeat (32400) @(posedge clk);
        $display("[INFO] @ %0t: Testing 1'h Rollover", $time);
        if (clock_combined != 24'h100000) $fatal(1, "[FATAL] @ %0t: 1'h Rollover Behaviour Incorrect!", $time);
        $display("[INFO] @ %0t: 1'h Rollover Behaviour OK!", $time);

        repeat (50400) @(posedge clk);
        $display("[INFO] @ %0t: Testing 24h Rollover", $time);
        if (clock_combined != 24'h0) $fatal(1, "[FATAL] @ %0t: 24h Rollover Behaviour Incorrect!", $time);
        $display("[INFO] @ %0t: 24h Rollover Behaviour OK!", $time);

        $display("[INFO] @ %0t: Design OK!", $time);

        $finish;
    end

endmodule