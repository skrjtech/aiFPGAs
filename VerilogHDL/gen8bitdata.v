
module GEN8BITDATA (
    input  wire       NRESET ,
    input  wire       POS    ,
    output wire [7:0] DATAO
);

    reg [7:0] data = 0;
    assign DATAO = data;
    always @(posedge POS, negedge NRESET) begin
        if (!NRESET) begin
            data = 0;
        end else begin
            data = data + 1'b1;
        end
    end

endmodule