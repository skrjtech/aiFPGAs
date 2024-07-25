`timescale 1us/100ps

`define SCYCLE     20                                    // 50MHz Main Clock
`define DWIDTH     8                                     // ビット幅
`define BYTES      8                                     // 全Byte
`define UARTMHZ    50000000                              // ペリフェラルヘルツ
`define BAUDRATE   115200                                // ボードレート
`define BAUDSCYCLE `SCYCLE * (`UARTMHZ / `BAUDRATE) * 10 // ボードサイクル

module uart_src_sink_tb; // メイン

// 必要に応じて
integer i, j, k;

reg clock;
reg reset;
always #(`SCYCLE / 2) clock = ~clock; // ＿|￣|＿|￣|＿|￣|＿|￣|＿|￣

host_to_kernel     u_host_to_kernel();
from_host_to_kenel u_from_host_to_kernel();
always @(*) begin
    // Host 
    u_host_to_kernel.clock = clock;
    u_host_to_kernel.reset = reset;
    // Kernel
    u_from_host_to_kernel.clock = clock;
    u_from_host_to_kernel.reset = reset;
end
assign u_from_host_to_kernel.rx = u_host_to_kernel.tx;

// Main Task
initial begin
    clock = 1;
    reset = 0;
    #(`SCYCLE * 1);
    reset = 1;
    #(`SCYCLE * 1);

    u_host_to_kernel.SendByteData({32'hB1B0_AFAE, 32'hADAC_ABAA});
    u_host_to_kernel.SendByteData({32'hB1B0_AFAE, 32'hADAC_ABAA + 1});

    #(`BAUDSCYCLE);

    $stop;
end

endmodule

// Host to Kernel
// ------------------------------------------------------------------------------------------------
module host_to_kernel;

// 必要に応じて
integer i, j, k;

reg clock;
reg reset;

wire                             tx;
wire                             uart_src_done;
reg                              uart_src_fen = 0;
reg  [(`BYTES * `DWIDTH) - 1: 0] uart_src_fdata = {(`BYTES * `DWIDTH){1'b0}};

UartSource #(
    .SCYCLE     (`UARTMHZ      ),
    .BAUDRATE   (`BAUDRATE     ),
    .BYTES      (`BYTES        )
) uUartSrc (
    .iCLOCK     (clock         ),
    .iNRESET    (reset         ),
    .iFEN       (uart_src_fen  ),
    .iFDATA     (uart_src_fdata), 
    .oTX        (tx            ),
    .oDONE      (uart_src_done )
);

task SendByteData;
input [(`BYTES * `DWIDTH) - 1: 0] data;
reg Break;
begin
    Break = 1'b0;

    uart_src_fdata = data;
    uart_src_fen   = 1'b1; #(`SCYCLE * 1)
    uart_src_fen   = 1'b0;
    while (!Break) begin
        #(`SCYCLE * 1);
        Break = (uart_src_done) ? !Break: Break;
    end
end
endtask
    
endmodule

// From Host To Kernel
// ------------------------------------------------------------------------------------------------
module from_host_to_kenel;
    
// 必要に応じて
integer i, j, k;

reg clock;
reg reset;

wire                             rx;
wire [(`BYTES * `DWIDTH) - 1: 0] uart_sink_data;
wire                             uart_sink_done;
wire                             uart_sink_recept;

UartSink #(
    .SCYCLE     (`UARTMHZ        ),
    .BAUDRATE   (`BAUDRATE       ),
    .BYTES      (`BYTES          )
) uUartSink (
    .iCLOCK     (clock           ),
    .iNRESET    (reset           ),
    .iRX        (rx              ),
    .oRECEPT    (uart_sink_recept),
    .oDONE      (uart_sink_done  ),
    .oFDATA     (uart_sink_data  )
);

endmodule