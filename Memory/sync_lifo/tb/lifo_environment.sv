/// --------------------------------------------------------
/// lifo_environment.sv
/// Ken The Nugget
/// Environment Class LIFO Memory TB
/// --------------------------------------------------------

class lifo_environment;

    lifo_agent                      agent;
    lifo_scoreboard                 scoreboard;
    mailbox #(lifo_transaction)     mbx_g2d;
    mailbox #(lifo_transaction)     mbx_m2s;

    function new(virtual lifo_interface vif, int num_tr);
        $display ("[INFO] %0t: Creating the apb_slave_environment", $time);
        mbx_g2d     = new(1);
        mbx_m2s     = new(1);
        agent       = new(mbx_g2d, mbx_m2s, vif, num_tr);
        scoreboard  = new(mbx_m2s);
    endfunction //new

    virtual task run();
        $display ("[INFO] %0t: Running lifo_environment", $time);
        fork
            scoreboard.run();
        join_none
        fork
            agent.run();
        join
    endtask // run

endclass // lifo_environment
