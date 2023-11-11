
module GENERATOR8BITDATA (
    input wire          CLK,
    input wire          RESET,
    input wire          SEC1POS,
    output wire [7:0]   DATA
);

    reg [7:0]   data;
    assign DATA = data;
    always @(posedge CLK, negedge RESET) begin
        if (~RESET) begin
            data <= 0;
        end else begin
            if (SEC1POS) begin
                if (data == 8'hFF) data <= 0;
                else data <= data + 1;
            end else begin
                data <= data;
            end
        end
    end

endmodule