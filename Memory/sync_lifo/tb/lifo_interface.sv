/// --------------------------------------------------------
/// lifo_interface.sv
/// Ken The Nugget
/// LIFO Memory TB Interface
/// --------------------------------------------------------

interface lifo_interface(
    input   logic   clk
);

    logic           reset_n;
    logic           write_en;
    logic           read_en;
    logic [7:0]     data_in;

    logic           full;
    logic           empty;
    logic [7:0]     data_out;


    clocking cb @(posedge clk);
        inout       reset_n;
        inout       write_en;
        inout       read_en;
        inout       data_in;
        
        inout       full;
        inout       empty;
        inout       data_out;
    endclocking
    
endinterface // lifo_interface
