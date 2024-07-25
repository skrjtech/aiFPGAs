module UARTCMD (
    input wire clk,
    input wire reset,

    input wire fifo_empty,
    output reg fifo_request,
    input wire [31:0] data_in,

    output reg [31:0] CMD,
    output reg [31:0] data_add,
    output reg [31:0] data_out,
    output reg done
);
    
localparam 
    IDLE = 0,
    BUSY = 1;

localparam
    CMD_MODE  = 0,
    SIZE_MODE = 1,
    ADDR_MODE = 2,
    DATA_MODE = 3;

reg state = 0;
reg [1:0] cmd_state = 0;

reg add_data = 0;
reg [31:0] SIZE = 0;
reg [31:0] COUNT = 0;
reg switch = 0;
always @(posedge clk, negedge reset) begin
    if (!reset) begin
        done <= 0;
        state <= 0;
        cmd_state <= 0;
        SIZE <= 0;
        COUNT <= 0;
        switch <= 0;
    end else begin
        case (state)
            IDLE: begin
                if (!fifo_empty) begin
                    fifo_request <= 1;
                    state <= BUSY;
                end else begin
                    fifo_request <= 0;
                    state <= IDLE;
                end
            end
            BUSY: begin
                if (fifo_request && !fifo_empty) begin
                    case (cmd_state)
                        CMD_MODE: begin
                            if (!switch) begin
                                switch <= ~switch; 
                            end else begin
                                CMD <= data_in;
                                cmd_state <= SIZE_MODE;
                                switch <= ~switch; 
                            end
                        end
                        SIZE_MODE: begin
                            if (!switch) begin
                                switch <= ~switch; 
                            end else begin
                                SIZE <= data_in;
                                cmd_state <= ADDR_MODE;
                                switch <= ~switch; 
                            end
                        end
                        ADDR_MODE: begin
                            if (!switch) begin
                               switch <= ~switch; 
                            end else begin
                                data_add <= data_in;
                                cmd_state <= DATA_MODE;
                                switch <= ~switch; 
                            end
                        end
                        DATA_MODE: begin
                            if (!switch) begin
                               switch <= ~switch; 
                            end else begin
                                data_out <= data_in;
                                switch <= ~switch;
                                COUNT <= COUNT + 1;
                                if (SIZE == COUNT) begin
                                    cmd_state <= CMD_MODE;
                                    fifo_request <= 0;
                                    done <= 0;
                                end 
                            end
                        end
                        default: cmd_state <= CMD_MODE; 
                    endcase
                end
            end
            default: state <= IDLE; 
        endcase
    end
end
endmodule