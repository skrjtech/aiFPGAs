// `timescale 1us/1ps
// `define SCYCLE 20

// `define RANDOMMAX +2147483647
// `define RANDOMMIN -2147483648

// module tb;

//     localparam 
//         DWIDTH = 32, 
//         WORDS  = 1 << 12, 
//         SIZE   = $clog2(WORDS);

//     reg clock = 1, reset = 0;
//     always #(`SCYCLE / 2) clock = ~clock;

//     reg                  we_port_a   , we_port_b;
//     reg  [DWIDTH - 1: 0] datai_port_a, datai_port_b;

//     reg                 stream_a_en,    stream_b_en;
//     reg  [DWIDTH - 1:0] stream_a_start, stream_a_limit;
//     reg  [DWIDTH - 1:0] stream_b_start, stream_b_limit;
//     wire [DWIDTH - 1:0] stream_a_datai, stream_b_datai;
//     wire [SIZE   - 1:0] stream_a_addr,  stream_b_addr;
//     wire [DWIDTH - 1:0] stream_a_datao, stream_b_datao;
//     wire                stream_a_done,  stream_b_done;

//     DualBRAM #(
//         .DWIDTH        (DWIDTH      ),
//         .WORDS         (WORDS       )
//     ) dbram (
//         .CLOCK         (clock       ),

//         .WE_PORT_A     (we_port_a     ),
//         .ADDR_PORT_A   (stream_a_addr ),
//         .DATAI_PORT_A  (datai_port_a  ),
//         .DATAO_PORT_A  (stream_a_datai),

//         .WE_PORT_B     (we_port_b     ),
//         .ADDR_PORT_B   (stream_b_addr ),
//         .DATAI_PORT_B  (datai_port_b  ),
//         .DATAO_PORT_B  (stream_b_datai)
//     );

//     Streamer #(
//         .DWIDTH        (DWIDTH      )
//     ) stream_a (
//         .CLOCK         (clock       ),
//         .RESET         (reset       ),
//         .EN            (stream_a_en   ),
//         .START         (stream_a_start),
//         .LIMIT         (stream_a_limit),
//         .ADDR          (stream_a_addr ),
//         .DATAI         (stream_a_datai),
//         .DATAO         (stream_a_datao),
//         .DONE          (stream_a_done )
//     );

//     Streamer #(
//         .DWIDTH        (DWIDTH      )
//     ) stream_b (
//         .CLOCK         (clock       ),
//         .RESET         (reset       ),
//         .EN            (stream_b_en   ),
//         .START         (stream_b_start),
//         .LIMIT         (stream_b_limit),
//         .ADDR          (stream_b_addr ),
//         .DATAI         (stream_b_datai),
//         .DATAO         (stream_b_datao),
//         .DONE          (stream_b_done )
//     );

//     localparam 
//         IDIM = 32                    ,
//         ODIM = 32                    ,
//         ASIZE  = DWIDTH * IDIM       ,
//         BSIZE  = DWIDTH * ODIM       ,
//         OSIZE  = DWIDTH * IDIM * ODIM;
    
//     reg                 start;
//     reg  [ASIZE - 1: 0] stream_a;
//     reg  [BSIZE - 1: 0] stream_b;
//     wire [OSIZE - 1: 0] stream_o;
//     Neuron #(
//         .DWIDTH     (DWIDTH  ),
//         .IDIM       (IDIM    ),
//         .ODIM       (ODIM    )
//     ) neuron (
//         .CLOCK      (clock   ),
//         .START      (start   ),
//         .STREAM_A   (stream_a),
//         .STREAM_B   (stream_b),
//         .STREAM_O   (stream_o)
//     );

//     integer i, j;
//     // Initial 
//     initial begin
//         BramInit();
//     end

//     // Main Task    
//     initial begin
//         #(`SCYCLE * 1);
//         reset = 1;
//         #(`SCYCLE * 1);
//         start = 1;
//         for (i = 0; i < 3; i = i + 1) begin
//             StreamASet();
//             StreamBSet();
//             #(`SCYCLE * 1);
//         end
//         start = 0;
//         #(`SCYCLE * 1);
//         $stop; 
//     end

//     task BramInit;
//         for (i = 0; i < WORDS; i = i + 1) begin
//             dbram.MEM[i] = Random(5, 1);
//         end
//     endtask

//     task StreamASet;
//         if (IDIM == 1) begin
//             stream_a = Random(5, 1);
//         end else begin
//             for (j = 0; j < IDIM; j = j + 1) begin
//                 stream_a = {Random(5, 1), stream_a[ASIZE - DWIDTH - 1: 0]} >> DWIDTH;
//             end
//         end
//     endtask

//     task StreamBSet;
//         if (ODIM == 1) begin
//             stream_b = Random(5, 1);
//         end else begin
//             for (j = 0; j < ODIM; j = j + 1) begin
//                 stream_b = {Random(5, 1), stream_b[BSIZE - DWIDTH - 1: 0]} >> DWIDTH;
//             end
//         end
//     endtask

//     integer limit = 10;
//     task StreamRun;
//         stream_a_start = limit * 1;
//         stream_a_limit = limit * 2;
//         stream_b_start = limit * 2;
//         stream_b_limit = limit * 3;
//         for (i = 0; i < limit; i = i + 1) begin
//             stream_a_addr = i + stream_a_start;
//             stream_b_addr = i + stream_b_start;
//         end
//     endtask

//     function [31:0] itof;
//         input [32:0] in;
//         begin
//             case (in)
//                 0: itof = 31'h0000_0000;
//                 1: itof = 31'h3F80_0000;
//                 2: itof = 31'h4000_0000; 
//                 3: itof = 31'h4040_0000; 
//                 4: itof = 31'h4080_0000; 
//                 5: itof = 31'h40A0_0000; 
//                 6: itof = 31'h40C0_0000; 
//                 7: itof = 31'h40E0_0000; 
//                 8: itof = 31'h4100_0000; 
//                 9: itof = 31'h4110_0000; 
//                 default: itof = 31'h0000_0000;
//             endcase
//         end
//     endfunction

//     function [31:0] Random;
//         input [31:0] MAX;
//         input [31:0] MIN;
//         begin
//             Random = itof($urandom % (MAX - MIN + 1) + MIN);
//         end
//     endfunction    

// endmodule