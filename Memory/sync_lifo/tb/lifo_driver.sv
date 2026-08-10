/// --------------------------------------------------------
/// lifo_driver.sv
/// Ken The Nugget
/// Driver Class LIFO Memory TB
/// --------------------------------------------------------

class lifo_driver;

    mailbox #(lifo_transaction)     mbx_g2d;
    virtual lifo_interface          vif;
    int                             num_tr;

    function new(mailbox #(lifo_transaction) mbx_g2d, virtual lifo_interface vif, int num_tr);
        this.mbx_g2d    = mbx_g2d;
        this.vif        = vif;
        this.num_tr = num_tr;
    endfunction // new

    virtual task reset_seq();
        vif.cb.reset_n <= 1'b0;
        repeat (3) @vif.cb;
        vif.cb.reset_n <= 1'b1;
        @vif.cb;
    endtask // reset_seq

    ///------------------------------------
    /// Test run 16 Writes - 16 Reads
    ///------------------------------------
    virtual task run();
        lifo_transaction tr;
        vif.cb.write_en <= 1'b1;
        vif.cb.read_en  <= 1'b0;
        repeat (16) begin
            mbx_g2d.get(tr);
            vif.cb.data_in  <= tr.data_in;
            @vif.cb;
        end
        vif.cb.write_en <= 1'b0;
        vif.cb.read_en  <= 1'b1;
        repeat (16) begin
            mbx_g2d.get(tr);
            vif.cb.data_in  <= tr.data_in;
            @vif.cb;
        end
    endtask

endclass // lifo_driver
