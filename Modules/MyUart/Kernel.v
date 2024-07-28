
`define UARTMHZ  50000000
`define BAUDRATE 115200

module Kernel (
    input  wire        clock_48mhz,
    input  wire        reset,
    input  wire        rx,
    output wire        tx
);

wire clock;
PLLs PLLs_inst (
    .inclk0 (clock_48mhz),
    .c0     (clock      )
);

reg         txstart;
reg  [7: 0] txdata;
wire        txbusy, txdone;
// wire        rxbusy, rxdone;
// wire [7: 0] rxsata;

initial begin
    txstart = 0;
    txdata  = 8'b00000000;
end

UartTransmit #(
    .MAINCLOCK  (`UARTMHZ),
    .BAUDRATE   (`BAUDRATE)
) uUt (
    .i_clock    (clock  ),
    .i_n_reset  (reset  ),
    .i_request  (txstart),
    .i_data     (txdata ),
    .o_busy     (txbusy ),
    .o_done     (txdone ),
    .o_tx       (tx     )
);

reg [31: 0] counter = 0;
wire pos_t   = (counter == (50000000 - 1));
wire pos_t_1 = (counter == (50000000 - 2));
always @(posedge clock, negedge reset) begin
    if (!reset) begin
        counter <= 0;
    end else if (pos_t) begin
        counter <= 0;
    end else begin
        counter <= counter + 1;
    end
end

always @(posedge clock, negedge reset) begin
    if (!reset) begin
        txdata <= 0;
    end else if (pos_t_1) begin
        txdata <= txdata + 1'b1;
    end else begin
        txdata <= txdata;
    end
end

always @(posedge clock, negedge reset) begin
    if (!reset) begin
        txstart <= 0;
    end else if (pos_t) begin
        txstart <= 1;
    end else begin
        txstart <= 0;
    end
end

endmodule