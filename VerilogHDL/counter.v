
module COUNTER (
    input  wire        CLOCK,
    input  wire        NRESET,
    input  wire [31:0] SCYCLE,
    output wire        OUTP
);

    reg [31:0] cnt;
    wire pos = (cnt == (SCYCLE - 1'b1));
    assign OUTP = pos;
    always @(posedge CLOCK, negedge NRESET) begin
        if (!NRESET || pos) begin
            cnt <= 0;
        end else begin
            cnt <= cnt + 1'b1; 
        end
    end
    
endmodule