
module STSource (
	clk,
	reset,
	src_data,
	src_valid,
	src_ready);	

	input		clk;
	input		reset;
	output	[31:0]	src_data;
	output	[0:0]	src_valid;
	input		src_ready;
endmodule
