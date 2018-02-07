module ps2_keyboard(
	clk,
	ps2_clk,
	ps2_data,
	decoded_key,
	read_key
);

input clk;
inout ps2_clk;
inout ps2_data;
output reg [7:0] decoded_key = 0;
output reg read_key = 0;

reg [3:0] bitctr = 0;
reg num_bits = 0;
reg ps2_clk_sync = 0;
reg ps2_data_sync = 0;
reg [9:0] clk_filter_ctr = 0;

// Force both data and clock to high impedence. This signals
// the keyboard that it can send data.
assign ps2_clk = 1'bz;
assign ps2_data = 1'bz;

// Synchronize the PS/2 clock line using the global clock.
// Required in order for routing to succeed. We also do some
// filtering here and delay the clock to ensure that we read
// the pulse ~15us (aka in the middle of the pulse) after it 
// goes low. 
// Assumption: 50Mhz main clock, thus 750 cycles for 15us.
always @(posedge clk)
begin
	if (ps2_clk_sync != ps2_clk)
	begin
		if (clk_filter_ctr == 750)
			ps2_clk_sync <= ps2_clk;
		else
			clk_filter_ctr <= clk_filter_ctr + 1;
	end
	else
		clk_filter_ctr <= 0;
	ps2_data_sync <= ps2_data;
end

always @(negedge ps2_clk_sync)
begin
	case (bitctr)
	4'd0: 
		begin
			// Start bit; should always be 0
			bitctr <= bitctr + 1;
			num_bits <= 0;
			decoded_key <= 0;
		end
	4'd1, 4'd2, 4'd3, 4'd4, 4'd5, 4'd6, 4'd7, 4'd8:
		begin
			// Data bit.
			decoded_key[bitctr - 1] <= ps2_data_sync;
			if (ps2_data_sync)
				num_bits <= num_bits + 1;
			bitctr <= bitctr + 1;
		end
	4'd9:
		begin
			// Parity bit, which we're ignoring for now.
			bitctr <= bitctr + 1;
			read_key <= 1;
		end
	4'd10:
		begin
			// Stop bit; should always be 1.
			bitctr <= 0;
			read_key <= 0;
		end
	default:
		begin
			// Should never reach here.
			bitctr <= 0;
		end
	endcase
end

endmodule