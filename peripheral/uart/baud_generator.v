module baud_generator(
	clk,
	out_clk);

parameter BAUD_RATE = 115200;
parameter SYS_CLOCK_HZ = 50000000;

input clk;
output reg out_clk;

reg [15:0] baud_ctr = 0;

always @(posedge clk)
begin
	if (baud_ctr == (SYS_CLOCK_HZ / BAUD_RATE))
	begin
		baud_ctr <= 0;
		out_clk <= 1;
	end
	else
	begin
		baud_ctr <= baud_ctr + 1;
		out_clk <= 0;
	end
end

endmodule