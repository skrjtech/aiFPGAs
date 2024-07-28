`timescale 1ns/100ps

`define TB_SCYCLE 20 // 50MHz

module tb ();

reg clock = 0;
reg reset = 0;
always #(`TB_SCYCLE / 2) clock = ~clock;

sampleA uSample();
always @(*) begin
    uSample.clock = clock;
    uSample.reset = reset;
end

initial begin
    clock = 1;
    reset = 0;
    #(`TB_SCYCLE * 1);
    reset = 1;
    #(`TB_SCYCLE * 1);

    uSample.change = 0;

    #(`TB_SCYCLE * 80);

    uSample.change = 1;

    #(`TB_SCYCLE * 80);

    uSample.change = 0;

    #(`TB_SCYCLE * 80);

    uSample.change = 0;

    #(`TB_SCYCLE * 80);

    uSample.change = 1;

    #(`TB_SCYCLE * 80);

    uSample.change = 0;

    #(`TB_SCYCLE * 80);

    $stop;
end

endmodule

module sampleA();

reg clock = 1;
reg reset   = 0;

reg change;

reg [3: 0] state, next_state;
always @(posedge clock, negedge reset) begin
    if (!reset) begin
        state <= 0;
    end else begin
        state <= next_state;
    end
end
always @(*) begin
    case (state)
        0: next_state = (change) ? 1: 0;
        1: next_state = (change) ? 2: 0;
        2: next_state = (change) ? 3: 0;
        3: next_state = 0; 
        default: 
            next_state = 0;
    endcase
end

endmodule