
module FIFO (clk, reset, data_in, write_en, read_en, data_out, full, empty);

parameter 
    BITS = 32,
    SIZE = 2;

input wire clk;
input wire reset;
input wire [BITS - 1: 0] data_in;
input wire write_en, read_en;
output reg [BITS - 1:0] data_out;
output wire full, empty;

localparam
    MSIZE = 1 << SIZE;

reg [BITS - 1: 0] mem [MSIZE - 1: 0];
reg [MSIZE - 1: 0] read_ptr, write_ptr;
reg [MSIZE - 1: 0] counter;

initial begin 
    counter   = 0;
    read_ptr  = 0;
    write_ptr = 0;
end

assign full = (counter == (MSIZE - 1));
assign empty = (counter == 0);
always @(posedge clk, negedge reset) begin
    if (!reset) begin 
        write_ptr <= 0;
        read_ptr <= 0;
        counter <= 0;
    end else begin 
        if (write_en && !full) begin 
            mem[write_ptr] <= data_in;
            write_ptr <= write_ptr + 1;
            counter <= counter + 1;
        end
        if (read_en && !empty) begin
            data_out <= mem[read_ptr];
            read_ptr <= read_ptr + 1;
            counter <= counter - 1;
        end
    end
end
endmodule

module FIFO_8to32 (clk, reset, data_in, write_en, read_en, data_out, full, empty);

parameter 
    SIZE = 2;

input wire clk;
input wire reset;
input wire [7: 0] data_in;
input wire write_en, read_en;
output reg [31:0] data_out;
output wire full, empty;

localparam
    MSIZE = 1 << SIZE;

reg [31: 0] mem [MSIZE - 1: 0];
reg [MSIZE - 1: 0] write_ptr, read_ptr;
reg [2:0] counter;

initial begin 
    counter = 0;
    write_ptr = 0;
    read_ptr = 0;
end

assign full = (write_ptr == (MSIZE - 1));
assign empty = (write_ptr == read_ptr);
always @(posedge clk, negedge reset) begin
        if (!reset) begin
        write_ptr <= 0;
        read_ptr <= 0;
    end else begin
        if (write_en && !full) begin
            if (counter == 3) begin
               write_ptr <= (write_ptr + 1) % MSIZE; 
            end 
        end
        if (read_en && !empty) begin
            read_ptr <= (read_ptr + 1) % MSIZE;
        end 
    end
end
always @(posedge clk, negedge reset) begin
    if (!reset) begin 
        counter <= 0;
    end else begin
        if (write_en && !full) begin
            case (counter)
                0: mem[write_ptr][ 7: 0] <= data_in; 
                1: mem[write_ptr][15: 8] <= data_in; 
                2: mem[write_ptr][23:16] <= data_in;
                3: mem[write_ptr][31:24] <= data_in;
                default: mem[write_ptr] <= {32{1'bz}};
            endcase
            counter <= (counter + 1) % 4;
        end
        if (read_en && !empty) begin
            data_out <= mem[read_ptr];   
        end
    end
end
endmodule