`define SCYCLE_50MHZ
// `define SCYCLE_1GHZ
// `define SCYCLE_2P5GMHZ

`ifdef SCYCLE_50MHZ
    `timescale 1ns/100ps
    // 50MHz = 10^9 (GHZ) / 50*10^6 (MHZ)
    `define TB_SCYCLE   20
    `define MAINCLOCK   50_000_000
`elsif SCYCLE_1GHZ
    `timescale 1ps/1ps
    // 1GHz = 10^12 (THZ) / 1*10^9 (GHZ)
    `define TB_SCYCLE   1000
    `define MAINCLOCK   1_000_000_000
`elsif SCYCLE_2P5GMHZ
    `timescale 1ps/1ps
    // 50MHz = 10^12 (THZ) / 2.5*10^9 (MHZ)
    `define TB_SCYCLE   400
    `define MAINCLOCK   2_500_000_000
`endif

`define BAUDRATE    115200
`define NUMBITS     10
`define BAUDSCYCLE  (`MAINCLOCK / `BAUDRATE) * `NUMBITS * `TB_SCYCLE

module tb ();

reg clock = 0;
reg reset = 0;
always #(`TB_SCYCLE / 2) clock = ~clock;

reg        start;
reg [7: 0] data;
uart u_uart(clock, reset);
assign u_uart.txstart = start;
assign u_uart.txdata  = data;
assign u_uart.rx      = u_uart.tx;
initial begin
    start = 0;
    data  = 0;
end

initial begin
    clock = 1;
    reset = 0;
    #(`TB_SCYCLE * 1);
    reset = 1;
    #(`TB_SCYCLE * 1);
    data = 8'hEE;
    #(`TB_SCYCLE * 1);
    start = 1;
    #(`TB_SCYCLE * 1);
    start = 0;
    // #(`BAUDSCYCLE);
    while (!u_uart.txdone) #(`TB_SCYCLE * 1);
    $stop;
end

endmodule

module uart (
    input wire clock,
    input wire reset
);

wire rx, tx;
wire rxbusy, rxdone;
wire txbusy, txdone, txstart;
wire [7: 0] txdata, rxdata;

UART #(
    .SCYCLE     (`MAINCLOCK ),
    .BAUDRATE   (`BAUDRATE  )
) uUart (
    .CLK        (clock      ),
    .RESET      (reset      ),
    .TX         (tx         ),
    .TXDATA     (txdata     ),
    .TXSTART    (txstart    ),
    .TXBUSY     (txbusy     ),
    .TXDONE     (txdone     ),
    .RX         (rx         ),
    .RXDATA     (rxdata     ),
    .RXBUSY     (rxbusy     ),
    .RXDONE     (rxdone     )
);

endmodule