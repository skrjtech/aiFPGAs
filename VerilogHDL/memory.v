
// DispersionRandomMemory
module DRAM #(
    parameter
        DWIDTH = 8  , 
        WORDS  = 256, 
        ADDRS  = $clog2(WORDS)
) (
    input  wire                 CLOCK,   // メインクロック
    input  wire                 WE   ,   // 書き込みイネーブル
    input  wire [ADDRS  - 1: 0] ADDR ,   // 読み書きアドレス
    input  wire [DWIDTH - 1: 0] DATAI,   // データ入力
    output wire [DWIDTH - 1: 0] DATAO    // データ出力
);
    
    reg [DWIDTH - 1: 0] MEM [0: WORDS - 1];
    always @(posedge CLOCK) begin
        if (WE) begin
            MEM[ADDR] <= DATAI;
        end
    end

    assign DATAO = MEM[ADDR];

endmodule

//  BlockRandomMemory
module BRAM #(
    parameter
        DWIDTH = 8   , 
        WORDS  = 4096,
        ADDRS  = $clog2(WORDS)
) (
    input  wire                 CLOCK,   // メインクロック
    input  wire                 WE   ,   // 書き込みイネーブル
    input  wire [ADDRS  - 1: 0] ADDR ,   // 読み書きアドレス
    input  wire [DWIDTH - 1: 0] DATAI,   // データ入力
    output wire [DWIDTH - 1: 0] DATAO    // データ出力
);
    
    reg [DWIDTH - 1: 0] MEM [0: WORDS - 1];
    
    reg [DWIDTH - 1: 0] datao;
    always @(posedge CLOCK) begin
        if (WE) begin
            MEM[ADDR] <= DATAI;
        end
        datao = MEM[ADDR];
    end

    assign DATAO = datao;

endmodule

//  DualBlockRandomMemory
module DualBRAM #(
    parameter
        DWIDTH = 8   , 
        WORDS  = 4096,
        ADDRS  = $clog2(WORDS)
) (
    input  wire                 CLOCK,         // メインクロック
    // PORT A                   
    input  wire                 PORT_A_WE,     // 書き込みイネーブル
    input  wire [ADDRS  - 1: 0] PORT_A_ADDR,   // 読み書きアドレス
    input  wire [DWIDTH - 1: 0] PORT_A_DATAI,  // データ入力
    output wire [DWIDTH - 1: 0] PORT_A_DATAO,  // データ出力
    // PORT B                   
    input  wire                 PORT_B_WE,     // 書き込みイネーブル
    input  wire [ADDRS  - 1: 0] PORT_B_ADDR,   // 読み書きアドレス
    input  wire [DWIDTH - 1: 0] PORT_B_DATAI,  // データ入力
    output wire [DWIDTH - 1: 0] PORT_B_DATAO   // データ出力
);
    
    wire [1:0]           we    = {PORT_A_WE  , PORT_B_WE  };
    wire [ADDRS  * 2: 0] addr  = {PORT_A_ADDR, PORT_B_ADDR};
    wire [DWIDTH * 2: 0] datai = {PORT_A_DATAI, PORT_B_DATAI};
    
    wire [DWIDTH * 2: 0] datao;
    assign {PORT_A_DATAO, PORT_B_DATAO} = datao;

    reg [DWIDTH - 1: 0] MEM [0: WORDS - 1];

    generate
        genvar i;
        for (i = 0; i < 2; i = i + 1) begin: port_block
            always @(posedge CLOCK) begin
                if (we[i]) begin
                    MEM[addr[(ADDRS * (i + 1)): ADDRS * i]] <= datai[(ADDRS * (i + 1)): ADDRS * i];
                end
            end
            assign datao[(ADDRS * (i + 1)): ADDRS * i] = MEM[addr[(ADDRS * (i + 1)): ADDRS * i]];
        end
    endgenerate

endmodule