/// --------------------------------------------------------
/// lifo_generator.sv
/// Ken The Nugget
/// Generator Class LIFO Memory TB
/// --------------------------------------------------------

class lifo_generator;

    mailbox #(lifo_transaction)     mbx_g2d;
    lifo_transaction                blueprint;
    
    function new(mailbox #(lifo_transaction) mbx_g2d);
        $display("[INFO] @ %0t: Creating the lifo_generator", $time);
        this.mbx_g2d    = mbx_g2d;
        blueprint       = new();
    endfunction // new

    virtual task run();
        forever begin
             void'(blueprint.randomize);
             mbx_g2d.put(blueprint.copy);
             blueprint.display("[GEN]");
        end
    endtask // run

endclass // lifo_generator
