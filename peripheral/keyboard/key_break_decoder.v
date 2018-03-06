module key_break_decoder(
	global_clk,
	key_data_in,
	key_changed,
	key_out,
	key_break_out,
	key_changed_out);
	
input global_clk;
input [7:0] key_data_in;
input key_changed;
output reg [15:0] key_out;
output reg key_break_out;
output reg key_changed_out;

reg [1:0] current_state = 0;
reg extended_seen = 0;

always @(posedge global_clk)
begin
	if (key_changed)
	begin
		case (current_state)
		0: begin
			if (key_data_in == 8'he0)
			begin
				current_state <= 1;
				key_out[15:8] <= key_data_in;
				key_break_out <= 0;
			end
			else if (key_data_in == 8'hf0)
			begin
				key_break_out <= 1;
				current_state <= 2;
			end
			else
			begin
				key_out <= {8'h00, key_data_in};
				key_changed_out <= 1;
				key_break_out <= 0;
				current_state <= 3;
			end
		end
		1: begin
			if (key_data_in == 8'hf0)
			begin
				key_break_out <= 1;
				current_state <= 2;
			end
			else
			begin
				key_out[7:0] <= key_data_in;
				key_changed_out <= 1;
				current_state <= 3;
			end
		end
		2: begin
			key_out[7:0] <= key_data_in;
			key_changed_out <= 1;
			current_state <= 3;
		end
		default: begin
			// Should not reach here; handled by top level else.
			current_state <= 0;
		end
		endcase
	end
	else if (current_state == 3)
	begin
		// Outside of case block above to ensure that key_changed_out is only pulsed
		// and does not stay on.
		key_changed_out <= 0;
		current_state <= 0;
	end
end

endmodule