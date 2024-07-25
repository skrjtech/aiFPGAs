
module Slave #(
    parameter
        BASEADDRES = 32'h0000_0000,
        ADDR_WIDTH = 5,
        WORDS      = 1024
) (
    input  wire [ADDR_WIDTH - 1: 0] ADDRI,
    output wire [ADDR_WIDTH - 1: 0] ADDRO,
    output wire                     REQ
);

    wire [ADDR_WIDTH - 1: 0] address = (ADDRI - BASEADDRES);
    assign REQ = (BASEADDRES <= ADDRI && ADDRI < (BASEADDRES + WORDS));
    assign ADDRO = address; 
    
endmodule