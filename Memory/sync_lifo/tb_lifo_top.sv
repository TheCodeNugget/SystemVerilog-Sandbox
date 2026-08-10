/// --------------------------------------------------------
/// tb_lifo_top.sv
/// Ken The Nugget
/// TOP File for LIFO Memory TB
/// --------------------------------------------------------

`timescale 1ns/1ns

`include "tb/lifo_interface.sv"

`include "tb/lifo_transaction.sv"
`include "tb/lifo_generator.sv"
`include "tb/lifo_driver.sv"
`include "tb/lifo_monitor.sv"
`include "tb/lifo_agent.sv"
`include "tb/lifo_scoreboard.sv"
`include "tb/lifo_environment.sv"

module tb_lifo_top();

    ///------------------------------------
    /// Internal Signals
    ///------------------------------------
    logic                   clk;
    lifo_environment        env;
    int                     num_tr;

    ///------------------------------------
    /// Dumpfile Setup
    ///------------------------------------
    initial begin
        $dumpfile("sync_lifo.vcd");
        $dumpvars(1, tb_lifo_top);
    end

    ///------------------------------------
    /// Create Interface
    ///------------------------------------
    lifo_interface lifo_if (
        .clk                (clk)
    );

    ///------------------------------------
    /// Instantiate DUT
    ///------------------------------------
    sync_lifo DUT (
        .clk                (clk),
        .reset_n            (lifo_if.reset_n),

        .write_en           (lifo_if.write_en),
        .read_en            (lifo_if.read_en),
        .data_in            (lifo_if.data_in),

        .empty              (lifo_if.empty),
        .full               (lifo_if.full),
        .data_out           (lifo_if.data_out)
    );

    ///------------------------------------
    /// Generate Clock
    ///------------------------------------
    initial clk = 1'b0;
    always #5 clk = ~clk;

    ///------------------------------------
    /// Run Tests
    ///------------------------------------
    initial begin
        num_tr = 32;
        env = new(lifo_if, num_tr);
        env.run();
        @(posedge clk);
        $finish;
    end

endmodule
