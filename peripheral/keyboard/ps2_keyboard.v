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
reg [10:0] timeout_ctr = 0;
reg timeout_en = 0;
reg timed_out = 0;

// Force both data and clock to high impedence. This signals
// the keyboard that it can send data.
assign ps2_clk = 1'bz;
assign ps2_data = 1'bz;

// Synchronize the PS/2 clock line using the global clock.
// Required in order for routing to succeed. We also do some
// filtering here and delay the clock to ensure that we read
// the pulse ~15us (aka in the middle of the pulse) after it 
// goes low. 
//
// Also, we want to have a 30us timeout for the clock to handle
// disconnect cases. If the clock edge doesn't switch within
// that time period, it's safe to assume that we've timed out
// and thus able to jump back to the beginning state of the decode
// process.
//
// Assumption: 50Mhz main clock, thus 750 cycles for 15us and 1500
// for 30us.
always @(posedge clk)
begin
	if (ps2_clk_sync != ps2_clk)
	begin
		if (clk_filter_ctr == 750)
		begin
			ps2_clk_sync <= ps2_clk;
			timeout_ctr <= 0;
			timeout_en <= 1;
		end
		else
			clk_filter_ctr <= clk_filter_ctr + 1;
	end
	else
	begin
		clk_filter_ctr <= 0;
		if (timeout_en)
		begin
			timeout_ctr <= timeout_ctr + 1;
			if (timeout_ctr >= 1500)
			begin
				// Flip timed_out long enough for the always block below
				// to see it and reset itself appropriately.
				if (timeout_ctr == 1500) timed_out <= 1;
				if (ps2_clk_sync) ps2_clk_sync <= 0;
				else if (!ps2_clk_sync && timeout_ctr > 1500) 
				begin
					ps2_clk_sync <= 1;
					timeout_en <= 0;
					timed_out <= 0;
				end
				else ps2_clk_sync <= 1;
			end
		end
	end
	ps2_data_sync <= ps2_data;
end

always @(negedge ps2_clk_sync)
begin
	if (timed_out) bitctr <= 0;
	else
	begin
		case (bitctr)
		4'd0: 
			begin
				// Start bit; should always be 0. If not,
				// we lost sync and need to stay in this state
				// until we actually receive 0.
				if (!ps2_data_sync)
				begin
					bitctr <= bitctr + 1;
					num_bits <= 0;
					decoded_key <= 0;
				end
				else
					bitctr <= 0;
			end
		4'd1, 4'd2, 4'd3, 4'd4, 4'd5, 4'd6, 4'd7, 4'd8:
			begin
				// Data bit. These arrive in LSB order.
				decoded_key[bitctr - 1] <= ps2_data_sync;
				if (ps2_data_sync)
					num_bits <= num_bits + 1;
				bitctr <= bitctr + 1;
			end
		4'd9:
			begin
				// Parity bit. 1 here indicates an even number of ones
				// in the byte we just read (num_bits == 0), while 0 indicates
				// an odd number of bits (num_bits == 1). If num_bits doesn't
				// jive with this value, we should throw out this byte and
				// wait for the next one.
				if (~num_bits == ps2_data_sync)
				begin
					bitctr <= bitctr + 1;
					read_key <= 1;
				end
				else
					bitctr <= 0;
			end
		4'd10:
			begin
				// Stop bit; should always be 1. We're not verifying it
				// here because we'll be resetting bitctr regardless.
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
end

endmodule