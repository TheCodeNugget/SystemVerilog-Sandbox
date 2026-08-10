/// --------------------------------------------------------
/// lifo_monitor.sv
/// Ken The Nugget
/// Monitor Class LIFO Memory TB
/// --------------------------------------------------------

class lifo_monitor;

    mailbox #(lifo_transaction)     mbx_m2s;
    virtual lifo_interface          vif;
    lifo_transaction                tr;

    function new(mailbox #(lifo_transaction) mbx_m2s, virtual lifo_interface vif);
        $display("[INFO] @ %0t: Creating the lifo_monitor", $time);
        this.mbx_m2s    = mbx_m2s;
        this.vif        = vif;
        tr              = new();
    endfunction // new

    virtual task run();
        forever begin
            @vif.cb;
            if ((vif.cb.read_en & !vif.cb.empty) | (vif.cb.write_en & !vif.cb.full)) begin
                tr.write_en     = vif.cb.write_en;
                tr.read_en      = vif.cb.read_en;
                tr.data_in      = vif.cb.data_in;
                tr.data_out     = vif.cb.data_out;
                mbx_m2s.put(tr);
            end
        end
    endtask

endclass // lifo_monitor
