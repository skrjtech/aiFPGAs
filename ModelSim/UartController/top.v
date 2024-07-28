module Kernel (
    input  wire clk48,
    input  wire reset,
    output wire tx
);

wire clock;
PLLs	PLLs_inst (
	.inclk0 ( clk48 ),
	.c0 ( clock )
	);

reg [31: 0] scycle = 0;
wire           pos = (scycle == 50_000_000 - 1);
always @(posedge clock) begin
    if (pos) begin
        scycle <= 0;
    end else begin
        scycle <= scycle + 1;
    end
end

reg [ 63: 0] data = {64{1'b0}} + 1'b1;
wire busy, done;

UartTransmitFrame #(
    .MAINCLOCK  (50000000),
    .BAUDRATE   (115200)
) uUtF (
    .i_clock    (clock),
    .i_n_reset  (reset),
    .i_request  (pos),
    .i_data     (data ),
    .o_busy     (busy ),
    .o_done     (done ),
    .o_tx       (tx   )
);

always @(posedge clock, negedge reset) begin: count_up
    if (!reset) begin
        data <= {64{1'b0}} + 1'b1;
    end else if (done) begin
        data <= data + 1'b1;
    end else begin
        data <= data;
    end
end
    
endmodule

module Kernel_no_pll (
    input  wire clock,
    input  wire reset,
    output wire tx
);

reg [31: 0] scycle = 0;
wire           pos = (scycle == 50_000_000 - 1);
always @(posedge clock) begin
    if (pos) begin
        scycle <= 0;
    end else begin
        scycle <= scycle + 1;
    end
end

reg [ 63: 0] data = {64{1'b0}} + 1'b1;
wire busy, done;

UartTransmitFrame #(
    .MAINCLOCK  (50000000),
    .BAUDRATE   (115200)
) uUtF (
    .i_clock    (clock),
    .i_n_reset  (reset),
    .i_request  (pos),
    .i_data     (data ),
    .o_busy     (busy ),
    .o_done     (done ),
    .o_tx       (tx   )
);

always @(posedge clock, negedge reset) begin: count_up
    if (!reset) begin
        data <= {64{1'b0}} + 1'b1;
    end else if (done) begin
        data <= data + 1'b1;
    end else begin
        data <= data;
    end
end
    
endmodule