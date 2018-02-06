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

// Force both data and clock to high impedence. This signals
// the keyboard that it can send data.
assign ps2_clk = 1'bz;
assign ps2_data = 1'bz;

// Synchronize the PS/2 clock line using the global clock.
// Required in order for routing to succeed.
always @(posedge clk)
begin
	ps2_clk_sync <= ps2_clk;
	ps2_data_sync <= ps2_data;
end

always @(negedge ps2_clk_sync)
begin
	case (bitctr)
	3'd0: 
		begin
			// Start bit; should always be 0
			bitctr <= bitctr + 1;
			num_bits <= 0;
			decoded_key <= 0;
		end
	3'd1, 3'd2, 3'd3, 3'd4, 3'd5, 3'd6, 3'd7, 3'd8:
		begin
			// Data bit.
			decoded_key[bitctr - 1] <= ps2_data_sync;
			if (ps2_data_sync)
				num_bits <= num_bits + 1;
			bitctr <= bitctr + 1;
		end
	3'd9:
		begin
			// Parity bit, which we're ignoring for now.
			bitctr <= bitctr + 1;
			read_key <= 1;
		end
	3'd10:
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