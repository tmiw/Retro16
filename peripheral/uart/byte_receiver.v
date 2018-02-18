module byte_receiver(
	clk,
	baud_oversample_clk,
	byte_was_received,
	byte_data,
	uart_rx_pin);
	
input clk;
input baud_oversample_clk;
input uart_rx_pin;
output byte_was_received;
output reg [7:0] byte_data = 0;

reg [1:0] filter_ctr = 2'b00;
reg received_bit = 1;
reg [3:0] current_rx_state = 0;
reg [2:0] oversample_ctr = 0;
wire next_bit = oversample_ctr == 7;

assign byte_was_received = current_rx_state == 9;

always @(posedge clk)
begin
	if (baud_oversample_clk && received_bit != uart_rx_pin)
	begin
		filter_ctr <= filter_ctr + 1;
		if (filter_ctr == 2'b11)
		begin
			received_bit <= uart_rx_pin;
		end
	end
	else if (baud_oversample_clk)
		filter_ctr <= 0;
end

always @(posedge clk)
begin
	if (baud_oversample_clk)
	begin
		case (current_rx_state)
		0: begin
			if (~received_bit)
			begin
				current_rx_state <= 1;
				oversample_ctr <= 0;
			end
		end
		1, 2, 3, 4, 5, 6, 7, 8: begin
			if (next_bit)
			begin
				byte_data[current_rx_state - 1] <= received_bit;
				oversample_ctr <= 0;
				current_rx_state <= current_rx_state + 1;
			end
			else
			begin
				oversample_ctr <= oversample_ctr + 1;
			end
		end
		9: begin
			if (next_bit)
			begin
				oversample_ctr <= 0;
				current_rx_state <= 0;
			end
			else
			begin
				oversample_ctr <= oversample_ctr + 1;
			end
		end
		default: begin
			// Should not reach here.
			oversample_ctr <= 0;
			current_rx_state <= 0;
		end
		endcase
	end
end

endmodule