
module Top (
    input wire clk,
    input wire reset,
    output reg tx,
    output wire [7:0] led
);

    reg [25:0] cnt1sec;
    wire sec1pos;
    assign sec1pos = (cnt1sec == (48_000_000 - 1));
    always @(posedge clk, negedge reset) begin
        if (~reset) cnt1sec = 0;
        else if (sec1pos) cnt1sec = 0;
        else cnt1sec = cnt1sec + 1;
    end

    reg [7:0] data;
    always @(posedge sec1pos, negedge reset) begin
        if (~reset) data <= 0;
        else if (data == (8'b1111_1111 - 1)) data = 0; 
        else data = data + 1;
    end

    assign led = data;

    localparam CLKFREQ = 48_000_000;
    localparam BAUDRATE = 9600;


    wire tx_start;
    assign tx_start = (cnt1sec == (48_000_000 - 1));

    reg [31:0] cnt;
    reg [3:0] bit_idx;
    reg [9:0] tx_shift_reg;
    wire tx_busy = |bit_idx;

    always @(posedge clk, negedge reset) begin
        if (~reset) begin
            cnt <= 32'd0;
            bit_idx <= 4'd0;
            tx <= 1'b1;
        end else begin
            if (tx_start && !tx_busy) begin
                tx_shift_reg <= {1'b1, data, 1'b0};
                bit_idx <= 4'd10;
            end
            if (tx_busy) begin
                if (cnt == (CLKFREQ / BAUDRATE)) begin
                    tx <= tx_shift_reg[0];
                    tx_shift_reg <= {1'b1, tx_shift_reg[9:1]};
                    bit_idx <= bit_idx - 1;
                    cnt <= 32'd0;
                end else begin
                    cnt <= cnt + 1;
                end
            end
        end
    end


endmodule