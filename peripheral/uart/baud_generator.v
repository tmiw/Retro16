module baud_generator(
	clk,
	out_clk,
	out_oversample_clk);

parameter BAUD_RATE = 115200;
parameter SYS_CLOCK_HZ = 50000000;
parameter OVERSAMPLE_AMOUNT = 8;

input clk;
output reg out_clk;
output reg out_oversample_clk;

reg [15:0] baud_ctr = 0;
reg [2:0] oversample_ctr = 0;

always @(posedge clk)
begin
	if (baud_ctr == (SYS_CLOCK_HZ / (BAUD_RATE * OVERSAMPLE_AMOUNT)))
	begin
		out_oversample_clk <= 1;
		baud_ctr <= 0;
		if (oversample_ctr == (OVERSAMPLE_AMOUNT - 1))
		begin
			out_clk <= 1;
			oversample_ctr <= 0;
		end
		else
		begin
			oversample_ctr <= oversample_ctr + 1;
		end
	end
	else
	begin
		baud_ctr <= baud_ctr + 1;
		out_clk <= 0;
		out_oversample_clk <= 0;
	end
end

endmodule