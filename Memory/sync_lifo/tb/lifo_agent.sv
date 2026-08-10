/// --------------------------------------------------------
/// lifo_agent.sv
/// Ken The Nugget
/// Agent Class for LIFO memory TB
/// --------------------------------------------------------

class lifo_agent;

    mailbox #(lifo_transaction)     mbx_g2d;
    mailbox #(lifo_transaction)     mbx_m2s;
    virtual lifo_interface          vif;
    int                             num_tr;
    lifo_generator                  gen;
    lifo_driver                     drv;
    lifo_monitor                    mon;

    function new(mailbox #(lifo_transaction) mbx_g2d, mailbox #(lifo_transaction) mbx_m2s, virtual lifo_interface vif, int num_tr);
        $display("[INFO] @ %0t: Creating the lifo_agent", $time);
        this.mbx_g2d    = mbx_g2d;
        this.mbx_m2s    = mbx_m2s;
        this.vif        = vif;
        this.num_tr     = num_tr;
        gen             = new(mbx_g2d);
        drv             = new(mbx_g2d, vif, num_tr);
        mon             = new(mbx_m2s, vif);
    endfunction //new

    virtual task run();
        drv.reset_seq();
        fork
            drv.run();
            gen.run();
            mon.run();
        join_any
    endtask // run

endclass //lifo_agent
