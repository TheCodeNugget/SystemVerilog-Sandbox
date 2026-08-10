/// --------------------------------------------------------
/// lifo_monitor.sv
/// Ken The Nugget
/// Monitor Class LIFO Memory TB
/// --------------------------------------------------------

class lifo_scoreboard;

    mailbox #(lifo_transaction)     mbx_m2s;
    lifo_transaction                tr;

    function new(mailbox #(lifo_transaction) mbx_m2s);
        $display("[INFO] @ %0t: Creating the lifo_transaction", $time);
        this.mbx_m2s    = mbx_m2s;
    endfunction // new

    virtual task run();
        forever begin
            mbx_m2s.get(tr);
            if (tr.write_en)    $display("[OP] @ %0t: Wrote 0x%h to LIFO", $time, tr.data_in);
            if (tr.read_en)     $display("[OP] @ %0t: Read 0x%h from LIFO", $time, tr.data_out);
        end
    endtask // run

endclass // lifo_scoreboard
