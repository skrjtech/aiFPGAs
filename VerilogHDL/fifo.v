module AsyncFIFO #(
    parameter
        BITS = 8,
        SIZE = 4
) (
    input  wire            RCLK, WCLK, RESET,
    input  wire            WE, RE,
    input  wire [BITS-1:0] DATAIN,
    output wire [BITS-1:0] Q,
    output wire            FULL, EMPTY 
);
/*
Description

    ・　先入れ先出し
    ・　ストリームデータ

    Parameter 
        None

    in : CLOCK      メイン・クロック　
    in : NRESET     ベガティブ・リセット
    in : SCYCLE     ?
    in : LIMIT      秒数制限
    out: OUT        
*/

// モジュール構成
// ----------------------------------------------
wire [SIZE-1:0] WADDR, RADDR;
wire [SIZE:0]   WRITE_POINTER, READ_POINTER, SYNC_WRITE_POINTER, SYNC_READ_POINTER;
ASYNC_FIFO_FULL      #(.SIZE(SIZE))              uFull  (.WCLK(WCLK), .RESET(RESET), .WE(WE), .SYNC_READ_POINTER(SYNC_READ_POINTER), .WRITE_ADDRESS(WADDR), .WRITE_POINTER(WRITE_POINTER), .WFULL(FULL)); 
ASYNC_FIFO_EMPTY     #(.SIZE(SIZE))              uEmpty (.RCLK(WCLK), .RESET(RESET), .RE(RE), .SYNC_WRITE_POINTER(SYNC_WRITE_POINTER), .READ_ADDRESS(RADDR), .READ_POINTER(READ_POINTER), .REMPTY(EMPTY));
SYNC_FIFO_READ2WRITE #(.SIZE(SIZE))              uSyncW (.WCLK(WCLK), .RESET(RESET), .READ_POINTER(READ_POINTER), .SYNC_READ_POINTER(SYNC_READ_POINTER));
SYNC_FIFO_WRITE2READ #(.SIZE(SIZE))              uSyncR (.RCLK(RCLK), .RESET(RESET), .WRITE_POINTER(WRITE_POINTER), .SYNC_WRITE_POINTER(SYNC_WRITE_POINTER));
ASYNC_FIFO_MEMORY    #(.BITS(BITS), .SIZE(SIZE)) uMem   (.WCLK(WCLK), .WE(WE), .FULL(FULL), .WADDR(WADDR), .RADDR(RADDR), .DATAIN(DATAIN), .DATAOUT(Q));

endmodule

module ASYNC_FIFO_FULL #(
    parameter
        SIZE = 4
) (
    input  wire            WCLK, RESET,
    input  wire            WE,
    input  wire [SIZE:0]   SYNC_READ_POINTER,
    output wire [SIZE-1:0] WRITE_ADDRESS,
    output reg  [SIZE:0]   WRITE_POINTER,
    output reg             WFULL
);
    reg  [SIZE:0] writeBin = 0;
    wire [SIZE:0] writeBinNext, writeGrayNext;
    wire   fullFlag = (writeGrayNext == ({~SYNC_READ_POINTER[SIZE:SIZE-1], SYNC_READ_POINTER[SIZE-2:0]}));
    assign WRITE_ADDRESS = writeBin[SIZE-1:0];
    assign writeBinNext = writeBin + (WE & ~WFULL);
    assign writeGrayNext = (writeBinNext >> 1) ^ writeBinNext;
    always @(posedge WCLK, negedge RESET) begin
        if (~RESET) begin
            WFULL <= 0;
            {writeBin, WRITE_POINTER} <= 0;
        end else begin
            WFULL <= fullFlag;
            {writeBin, WRITE_POINTER} <= {writeBinNext, writeGrayNext};
        end
    end
endmodule

module ASYNC_FIFO_EMPTY #(
    parameter
        SIZE = 4
) (
    input  wire            RCLK, RESET,
    input  wire            RE,
    input  wire [SIZE:0]   SYNC_WRITE_POINTER,
    output wire [SIZE-1:0] READ_ADDRESS,
    output reg  [SIZE:0]   READ_POINTER,
    output reg             REMPTY
);
    reg  [SIZE:0] readBin = 0;
    wire [SIZE:0] readBinNext, readGrayNext;
    wire   readFlag = (readGrayNext == SYNC_WRITE_POINTER);
    assign READ_ADDRESS = readBin[SIZE-1:0];
    assign readBinNext  = readBin + (RE & ~REMPTY);
    assign readGrayNext = (readBinNext >> 1) ^ readBinNext;
    always @(posedge RCLK, negedge RESET) begin
        if (~RESET) begin
            REMPTY <= 1;
            {readBin, READ_POINTER} <= 0;
        end else begin
            REMPTY <= readFlag;
            {readBin, READ_POINTER} <= {readBinNext, readGrayNext};
        end
    end
endmodule

module ASYNC_FIFO_MEMORY #(
    parameter
        BITS = 8,
        SIZE = 4
) (
    input  wire            WCLK, WE, FULL, 
    input  wire [SIZE-1:0] WADDR, RADDR,
    input  wire [BITS-1:0] DATAIN,
    output wire [BITS-1:0] DATAOUT
);
    localparam DEPTH = 1 << SIZE;
    reg [BITS-1:0] mem [DEPTH-1:0];
    assign DATAOUT = mem[RADDR];
    always @(posedge WCLK) begin
        if (WE && ~FULL) begin
            mem[WADDR] <= DATAIN;
        end
    end
endmodule

module SYNC_FIFO_WRITE2READ #(
    parameter
        SIZE = 4
) (
    input  wire          RCLK, RESET,
    input  wire [SIZE:0] WRITE_POINTER,
    output reg  [SIZE:0] SYNC_WRITE_POINTER
);
    reg [SIZE:0] FF;
    always @(posedge RCLK, negedge RESET) begin
        if (~RESET) begin
            {SYNC_WRITE_POINTER, FF} <= 0;
        end else begin
            {SYNC_WRITE_POINTER, FF} <= {FF, WRITE_POINTER};
            // SYNC_WRITE_POINTER <= WRITE_POINTER;
        end
    end
endmodule

module SYNC_FIFO_READ2WRITE #(
    parameter
        SIZE = 4
) (
    input  wire          WCLK, RESET,
    input  wire [SIZE:0] READ_POINTER,
    output reg  [SIZE:0] SYNC_READ_POINTER
);
    reg [SIZE:0] FF;
    always @(posedge WCLK, negedge RESET) begin
        if (~RESET) begin
            {SYNC_READ_POINTER, FF} <= 0;
        end else begin
            {SYNC_READ_POINTER, FF} <= {FF, READ_POINTER};
            // SYNC_READ_POINTER <= READ_POINTER;
        end
    end
endmodule

// module ASYNCFIFO #(
//     parameter
//         BITS = 8,
//         SIZE = 4
// ) (
//     input  wire            RCLK, WCLK, RESET,
//     input  wire            WE, RE,
//     input  wire [BITS-1:0] DATAIN,
//     output wire [BITS-1:0] Q,
//     output wire            FULL, EMPTY
// );
//     wire [SIZE-1:0] WADDR, RADDR;
//     wire [SIZE:0]   WRITE_POINTER, READ_POINTER, SYNC_WRITE_POINTER, SYNC_READ_POINTER;
//     ASYNC_FIFO_FULL      #(.SIZE(SIZE))              uFull  (.WCLK(WCLK), .RESET(RESET), .WE(WE), .SYNC_READ_POINTER(SYNC_READ_POINTER), .WRITE_ADDRESS(WADDR), .WRITE_POINTER(WRITE_POINTER), .WFULL(FULL)); 
//     ASYNC_FIFO_EMPTY     #(.SIZE(SIZE))              uEmpty (.RCLK(WCLK), .RESET(RESET), .RE(RE), .SYNC_WRITE_POINTER(SYNC_WRITE_POINTER), .READ_ADDRESS(RADDR), .READ_POINTER(READ_POINTER), .REMPTY(EMPTY));
//     SYNC_FIFO_READ2WRITE #(.SIZE(SIZE))              uSyncW (.WCLK(WCLK), .RESET(RESET), .READ_POINTER(READ_POINTER), .SYNC_READ_POINTER(SYNC_READ_POINTER));
//     SYNC_FIFO_WRITE2READ #(.SIZE(SIZE))              uSyncR (.RCLK(RCLK), .RESET(RESET), .WRITE_POINTER(WRITE_POINTER), .SYNC_WRITE_POINTER(SYNC_WRITE_POINTER));
//     ASYNC_FIFO_MEMORY    #(.BITS(BITS), .SIZE(SIZE)) uMem   (.WCLK(WCLK), .WE(WE), .FULL(FULL), .WADDR(WADDR), .RADDR(RADDR), .DATAIN(DATAIN), .DATAOUT(Q));
// endmodule

// module ASYNC_FIFO_FULL #(
//     parameter
//         SIZE = 4
// ) (
//     input  wire            WCLK, RESET,
//     input  wire            WE,
//     input  wire [SIZE:0]   SYNC_READ_POINTER,
//     output wire [SIZE-1:0] WRITE_ADDRESS,
//     output reg  [SIZE:0]   WRITE_POINTER,
//     output reg             WFULL
// );
//     reg  [SIZE:0] writeBin = 0;
//     wire [SIZE:0] writeBinNext, writeGrayNext;
//     wire   fullFlag = (writeGrayNext == ({~SYNC_READ_POINTER[SIZE:SIZE-1], SYNC_READ_POINTER[SIZE-2:0]}));
//     assign WRITE_ADDRESS = writeBin[SIZE-1:0];
//     assign writeBinNext = writeBin + (WE & ~WFULL);
//     assign writeGrayNext = (writeBinNext >> 1) ^ writeBinNext;
//     always @(posedge WCLK, negedge RESET) begin
//         if (~RESET) begin
//             WFULL <= 0;
//             {writeBin, WRITE_POINTER} <= 0;
//         end else begin
//             WFULL <= fullFlag;
//             {writeBin, WRITE_POINTER} <= {writeBinNext, writeGrayNext};
//         end
//     end
// endmodule

// module ASYNC_FIFO_EMPTY #(
//     parameter
//         SIZE = 4
// ) (
//     input  wire            RCLK, RESET,
//     input  wire            RE,
//     input  wire [SIZE:0]   SYNC_WRITE_POINTER,
//     output wire [SIZE-1:0] READ_ADDRESS,
//     output reg  [SIZE:0]   READ_POINTER,
//     output reg             REMPTY
// );
//     reg  [SIZE:0] readBin = 0;
//     wire [SIZE:0] readBinNext, readGrayNext;
//     wire   readFlag = (readGrayNext == SYNC_WRITE_POINTER);
//     assign READ_ADDRESS = readBin[SIZE-1:0];
//     assign readBinNext  = readBin + (RE & ~REMPTY);
//     assign readGrayNext = (readBinNext >> 1) ^ readBinNext;
//     always @(posedge RCLK, negedge RESET) begin
//         if (~RESET) begin
//             REMPTY <= 1;
//             {readBin, READ_POINTER} <= 0;
//         end else begin
//             REMPTY <= readFlag;
//             {readBin, READ_POINTER} <= {readBinNext, readGrayNext};
//         end
//     end
// endmodule

// module ASYNC_FIFO_MEMORY #(
//     parameter
//         BITS = 8,
//         SIZE = 4
// ) (
//     input  wire            WCLK, WE, FULL, 
//     input  wire [SIZE-1:0] WADDR, RADDR,
//     input  wire [BITS-1:0] DATAIN,
//     output wire [BITS-1:0] DATAOUT
// );
//     localparam DEPTH = 1 << SIZE;
//     reg [BITS-1:0] mem [DEPTH-1:0];
//     assign DATAOUT = mem[RADDR];
//     always @(posedge WCLK) begin
//         if (WE && ~FULL) begin
//             mem[WADDR] <= DATAIN;
//         end
//     end
// endmodule

// module SYNC_FIFO_WRITE2READ #(
//     parameter
//         SIZE = 4
// ) (
//     input  wire          RCLK, RESET,
//     input  wire [SIZE:0] WRITE_POINTER,
//     output reg  [SIZE:0] SYNC_WRITE_POINTER
// );
//     reg [SIZE:0] FF;
//     always @(posedge RCLK, negedge RESET) begin
//         if (~RESET) begin
//             {SYNC_WRITE_POINTER, FF} <= 0;
//         end else begin
//             {SYNC_WRITE_POINTER, FF} <= {FF, WRITE_POINTER};
//             // SYNC_WRITE_POINTER <= WRITE_POINTER;
//         end
//     end
// endmodule

// module SYNC_FIFO_READ2WRITE #(
//     parameter
//         SIZE = 4
// ) (
//     input  wire          WCLK, RESET,
//     input  wire [SIZE:0] READ_POINTER,
//     output reg  [SIZE:0] SYNC_READ_POINTER
// );
//     reg [SIZE:0] FF;
//     always @(posedge WCLK, negedge RESET) begin
//         if (~RESET) begin
//             {SYNC_READ_POINTER, FF} <= 0;
//         end else begin
//             {SYNC_READ_POINTER, FF} <= {FF, READ_POINTER};
//             // SYNC_READ_POINTER <= READ_POINTER;
//         end
//     end
// endmodule