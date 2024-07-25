`timescale 1us/100ps

`define SCYCLE 20 // 50MHz
`define HALF_SCYCLE `SCYCLE / 2

`define UARTMHZ  50_000_000
`define BAUDRATE 9600
`define TXRXSCYCLE `SCYCLE * (`UARTMHZ / `BAUDRATE)

module tb ();

reg clock = 1;
reg reset = 0;
always #(`HALF_SCYCLE) clock = ~clock;

uart_tx task_uart_tx (clock, reset);

reg read_en;
wire [31:0] data_out, CMD, addr, data;
wire done;
Top uTop (
    .clk (clock),
    .reset (reset),
    
    .rx (task_uart_tx.tx),
    
    .CMD  (CMD),
    .addr (addr),
    .data (data),
    .done (done)
);

initial begin

    #(`SCYCLE) reset = 1;

    task_uart_tx.SendByte(32'h0000_0001);
    task_uart_tx.SendByte(32'h0000_0004);

    task_uart_tx.SendByte(32'h0000_0000);
    task_uart_tx.SendByte($pow($sqrt($random), 2));

    task_uart_tx.SendByte(32'h0000_0001);
    task_uart_tx.SendByte($pow($sqrt($random), 2));
    
    task_uart_tx.SendByte(32'h0000_0002);
    task_uart_tx.SendByte($pow($sqrt($random), 2));
    
    task_uart_tx.SendByte(32'h0000_0003);
    task_uart_tx.SendByte($pow($sqrt($random), 2));

    #(`TXRXSCYCLE);
    $stop;
end

endmodule

module uart_tx (clock, reset);

parameter 
    SCYCLE = 50_000_000,
    BAUDRATE = 9600;

input wire clock, reset;

wire tx;
reg [7:0] txdata;
reg txstart; 
wire txbusy, txdone;

TXD #(
    .SCYCLE     (SCYCLE  ),
    .BAUDRATE   (BAUDRATE)
) uTxd (
    .CLK        (clock   ),
    .RESET      (reset   ),
    .TX         (tx      ),
    .TXDATA     (txdata  ),
    .TXSTART    (txstart ),
    .TXBUSY     (txbusy  ),
    .TXDONE     (txdone  )
);

task SendBit;
    input [7:0] in;
    begin
        txdata = in;
        txstart = 1;
        @(posedge clock);
        txstart = 0;
        while (!txdone) begin
            @(posedge clock);
        end
        @(posedge clock);
    end
endtask

task SendByte;
    input [31:0] in;
    begin
        SendBit(in[ 7: 0]);
        SendBit(in[15: 8]);
        SendBit(in[23:16]);
        SendBit(in[31:24]);
    end
endtask
    
endmodule