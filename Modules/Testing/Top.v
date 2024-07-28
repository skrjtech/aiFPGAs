
module Top (
    input  wire       clock,
    input  wire       reset,
    input  wire       txstart,
    input  wire [7:0] txdata,
    output wire       tx,
    output wire       txbusy,
    output wire       txdone
);

TxD uTxD(
    .iCLOCK  (clock  ),
    .iNRESET (reset  ),
    .iTXSTART(txstart),
    .iTXDATA (txdata ),
    .oTX     (tx     ),
    .oTXBUSY (txbusy ),
    .oTXDONE (txdone )
);
    
endmodule