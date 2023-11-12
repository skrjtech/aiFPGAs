
`ifdef SIMULATION
    `define SCYCLE 100
    `define BAUDRATE 25
    `define BITS 4
`else 
    `define SCYCLE 50_000_000
    `define BAUDRATE 9600
    `define BITS 13
`endif 

// `define SCYCLE 48_000_000
// `define BAUDRATE 9600
// `define BITS 32

module SERIAL (
    input  wire       clk   ,
    input  wire       reset ,
    input  wire       rx    ,
    output wire       tx    ,
    output wire [7:0] leds
);


// wire clk50;
// PLL uPLL (
//     .inclk0 (clk    ), 
//     .c0     (clk50  )
// );

wire [7:0] txdata, rxdata;
wire txbusy, txdone;
wire rxbusy, rxdone;
wire txstart;
assign leds = rxdata;

COUNTER #(
    .SCYCLE (`SCYCLE )
) uCounter (
    // .CLK        (clk50   ),
    .CLK        (clk     ),
    .RESET   (reset  ),
    .COUT    (txstart  )
);
GEN8BITDATA uGenD (
    // .CLK        (clk50   ),
    .CLK        (clk     ),
    .RESET   (reset   ),
    .SEC1POS (txstart ),
    .DATA    (txdata  )
);
UART #(
    `SCYCLE, `BAUDRATE, `BITS
) uUART (
    // .CLK        (clk50   ),
    .CLK        (clk     ),
    .RESET      (reset   ),
    
    .TX         (tx      ),
    .TXDATA     (txdata  ),
    .TXSTART    (txstart ),
    .TXBUSY     (txbusy  ),
    .TXDONE     (txdone  ),

    .RX         (tx      ),
    .RXDATA     (rxdata  ),
    .RXBUSY     (rxbusy  ),
    .RXDONE     (rxdone  )
);

endmodule