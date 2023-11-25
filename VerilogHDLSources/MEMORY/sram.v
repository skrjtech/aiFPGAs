
module SRAM1D #( 
    parameter 
        DATAWIDTH = 8,
        CAPACITOR = 1024,
        ADDRESSCP = $clog2(CAPACITOR)
) (
    input  wire                 CLK, RESET,
    input  wire [ADDRESSCP-1:0] ADDR,
    input  wire                 CS, RE, WE,
    input  wire [DATAWIDTH-1:0] DATAIN,
    output wire [DATAWIDTH-1:0] DATAOUT
);

    reg [DATAWIDTH-1:0] MEM [0:CAPACITOR-1];
    assign DATAOUT = (CS && RE) ? MEM[ADDR] : {DATAWIDTH{1'bz}};
    integer i;
    always @(posedge CLK, negedge RESET) begin
        if (~RESET) begin
            for (i = 0; i < CAPACITOR; i = i + 1) begin
                MEM[i] = {DATAWIDTH{1'b0}};
            end
        end else if (CS && WE) begin
            MEM[ADDR] <= DATAIN;
        end
    end
    
endmodule

module SRAM2D #( 
    parameter 
        DATAWIDTH = 8,
        ARRAYCAPX = 1024,
        ARRAYCAPY = 1024
) (
    input  wire                         CLK, RESET,
    input  wire [$clog2(ARRAYCAPX)-1:0] ADDRX,
    input  wire [$clog2(ARRAYCAPY)-1:0] ADDRY,
    input  wire                         CS, RE, WE,
    input  wire [DATAWIDTH-1:0]         DATAIN,
    output wire [DATAWIDTH-1:0]         DATAOUT
);

    reg [DATAWIDTH-1:0] MEM [0:ARRAYCAPX-1][0:ARRAYCAPY-1];
    assign DATAOUT = (CS && RE) ? MEM[ADDRX][ADDRY] : {DATAWIDTH{1'bz}};
    integer X, Y;
    always @(posedge CLK, negedge RESET) begin
        if (~RESET) begin
            for (Y = 0; Y < ARRAYCAPY; Y = Y + 1) begin
                for (X = 0; X < ARRAYCAPX; X = X + 1) begin
                   MEM[X][Y] = {DATAWIDTH{1'b0}}; 
                end
            end
        end else if (CS && WE) begin
            MEM[ADDRX][ADDRY] <= DATAIN;
        end
    end
    
endmodule