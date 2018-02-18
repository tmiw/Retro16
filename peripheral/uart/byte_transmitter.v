module byte_transmitter(
	clk,
	baud_clk,
	byte_to_transmit,
	begin_tx,
	uart_tx_pin);
	
// Assumptions: 8N1, RS-232. Code will need to be modified as appropriate
// for parity, additional stop bits, etc.

input clk;
input baud_clk;
input [7:0] byte_to_transmit;
input begin_tx;
output reg uart_tx_pin = 0;

reg [3:0] current_state = 0;

always @(posedge clk)
begin
	case (current_state)
	0: begin
		// Idle state; stay "high" unless told to transmit.
		uart_tx_pin <= 1;
		if (begin_tx)
			current_state <= 1;
	end
	1: begin
		// Synchronize on baud clock before beginning transmit.
		uart_tx_pin <= 1;
		if (baud_clk)
			current_state <= 2;
	end
	2: begin
		// Start bit; always 0.
		uart_tx_pin <= 0;
		if (baud_clk)
			current_state <= 3;
	end
	3, 4, 5, 6, 7, 8, 9, 10: begin
		// Data bits, LSB first.
		uart_tx_pin <= byte_to_transmit[current_state - 3];
		if (baud_clk)
			current_state <= current_state + 1;
	end
	11: begin
		// Stop bit, always high.
		uart_tx_pin <= 1;
		if (baud_clk)
			current_state <= 0;
	end
	default: begin
		// Should be impossible.
		current_state <= 0;
	end
	endcase
end

endmodule