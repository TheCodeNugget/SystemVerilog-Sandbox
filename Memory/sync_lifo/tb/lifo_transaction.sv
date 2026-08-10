/// --------------------------------------------------------
/// lifo_transaction.sv
/// Ken The Nugget
/// Generator Object LIFO Memory TB
/// --------------------------------------------------------

class lifo_transaction;
    
    bit                 write_en;
    bit                 read_en;
    bit [7:0]           data_out;
    rand bit [7:0]      data_in;

    constraint c1 {
        !(write_en & read_en);
    }

    virtual function void display(string prefix = "");
        $display("[INFO] @ %0t: %s Tr: data_in: 0x%h, data_out: 0x%h, ", $time, prefix, data_in, data_out);
    endfunction // display

    virtual function lifo_transaction copy();
        copy = new();
        copy.write_en   = this.write_en;
        copy.read_en    = this.read_en;
        copy.data_out   = this.data_out;
        copy.data_in    = this.data_in;
    endfunction // copy

endclass // lifo_transaction
