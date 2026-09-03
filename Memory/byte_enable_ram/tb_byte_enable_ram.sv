`timescale 1ns/1ns
module tb_byte_enable_ram;

    // --------------------------------------------------------
    // TB Params
    // --------------------------------------------------------
    parameter XLEN  = 32;
    parameter LINES = 8192;
    localparam ADDR_WIDTH = $clog2(LINES);

    // --------------------------------------------------------
    // TB to DUT connections
    // --------------------------------------------------------
    logic                     clk;
    logic                     reset_n;

    logic [ADDR_WIDTH-1:0]    addr_a;
    logic                     en_a;
    logic [XLEN/8-1:0]        be_a;
    logic [XLEN-1:0]          data_in_a;
    logic [XLEN-1:0]          data_out_a;

    logic [ADDR_WIDTH-1:0]    addr_b;
    logic                     en_b;
    logic [XLEN/8-1:0]        be_b;
    logic [XLEN-1:0]          data_in_b;
    logic [XLEN-1:0]          data_out_b;

    // --------------------------------------------------------
    // Instantiate DUT
    // --------------------------------------------------------
    byte_enable_ram #(
        .XLEN           (XLEN),
        .LINES          (LINES)
    ) DUT (
        .clk            (clk),
        .reset_n        (reset_n),
        .addr_a         (addr_a),
        .en_a           (en_a),
        .be_a           (be_a),
        .data_in_a      (data_in_a),
        .data_out_a     (data_out_a),
        .addr_b         (addr_b),
        .en_b           (en_b),
        .be_b           (be_b),
        .data_in_b      (data_in_b),
        .data_out_b     (data_out_b)
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
        reset_n   = 1'b0;
        addr_a    = 0;
        addr_b    = 0;
        en_a      = 0;
        en_b      = 0;
        be_a      = 4'b0000;  
        data_in_a = 32'h00000000;  
        be_b      = 4'b0000;  
        data_in_b = 32'h00000000;  
        repeat (3) @(posedge clk);
        reset_n = 1'b1;
    endtask

    task test_port_a();
        $display("[INFO] @ %0t: Testign Port-A", $time);
        addr_a    = 3;
        en_a      = 1;
        be_a      = 4'b0011;  
        data_in_a = 32'h00001234; 
        @(posedge clk);
        en_a      = 0;
        @(posedge clk);
        addr_a    = 3;
        en_a      = 1;
        be_a      = 4'b1100;  
        data_in_a = 32'hABCD0000; 
        @(posedge clk);
        en_a      = 0;
        @(posedge clk);
        if (data_out_a == 32'hABCD1234) begin
            $display("[PASS] @ %0t: Port-A OK!", $time);
        end else begin
            $error("[FAIL] @ %0t: Port-A Error Expected: 0xABCD1234 GOT: 0x%h", $time, data_out_a);
        end
    endtask

    task test_port_b();
        $display("[INFO] @ %0t: Testign Port-B", $time);
        addr_b    = 3;
        en_b      = 1;
        be_b      = 4'b0011;  
        data_in_b = 32'h0000BEEF; 
        @(posedge clk);
        en_b      = 0;
        @(posedge clk);
        addr_b    = 3;
        en_b      = 1;
        be_b      = 4'b1100;  
        data_in_b = 32'hCAFE0000; 
        @(posedge clk);
        en_b      = 0;
        @(posedge clk);
        if (data_out_b == 32'hCAFEBEEF) begin
            $display("[PASS] @ %0t: Port-B OK!", $time);
        end else begin
            $error("[FAIL] @ %0t: Port-B Error Expected: 0xCAFEBEEF GOT: 0x%h", $time, data_out_a);
        end
    endtask

    task test_port_collision();
        addr_a    = 2;
        addr_b    = 2;
        en_a      = 1;
        en_b      = 1;
        be_a      = 4'b0110;  
        data_in_a = 32'h01234567;  
        be_b      = 4'b1111;  
        data_in_b = 32'h89ABCDEF;  
        @(posedge clk);
        en_a      = 0;
        en_b      = 0;
        @(posedge clk);
        if (data_out_a == 32'h892345EF) begin
            $display("[PASS] @ %0t: Collision Handling OK!", $time);
        end else begin
            $error("[FAIL] @ %0t: Collision Error Expected: 0x892345EF GOT: 0x%h", $time, data_out_a);
        end
    endtask

    initial begin
        reset_device();
        test_port_a();
        test_port_b();
        test_port_collision();
        $display("[PASS] @ %0t: Design OK!", $time);
        $finish;
    end
endmodule