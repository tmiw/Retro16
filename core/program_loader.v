module program_loader(
	global_clk,
	core_clk,
	rst,
	ram_addr_out,
	ram_data_out,
	ram_write_enable,
	rs232_tx,
	rs232_rx,
	load_complete);

parameter MAX_LOAD_ADDRESS = 16'hC000;

input global_clk;
input core_clk;
input rst;
output reg [15:0] ram_addr_out = 0;
output reg [15:0] ram_data_out = 0;
output reg ram_write_enable = 0;
output rs232_tx;
input rs232_rx;
output reg load_complete = 0;

// Generate RS-232 clocks for TX/RX modules.
wire baud_clk;
wire baud_oversample_clk;
baud_generator rs232_baud(global_clk, baud_clk, baud_oversample_clk);

// RS-232 transmitter. Sends initial byte and ack bytes.
reg tx_byte_now;
reg [7:0] byte_to_tx;
byte_transmitter rs232_transmitter(global_clk, baud_clk, byte_to_tx, tx_byte_now, rs232_tx);

// RS-232 receiver. Receives program data from client.
wire byte_received_flag;
wire [7:0] byte_received;
byte_receiver rx232_receiver(global_clk, baud_oversample_clk, byte_received_flag, byte_received, rs232_rx);

// Loader state machine.
// Initial state: 
//    * Send welcome byte
//    * Set RAM address to 0x0000.
//    * Wait for additional input.
// While RAM address < 0xC000:
//    * Receive first byte of word
//    * Receive second byte
//    * Set WE to 1 
//    * On next clock:
//      * Set WE to 0
//      * Increment RAM address
// When RAM address == 0xC000:
//    * Set load_complete to 1
reg [2:0] current_state = 0;
always @(posedge global_clk)
begin
	if (rst)
	begin
		current_state <= 0;
		ram_addr_out <= 0;
		ram_data_out <= 0;
		ram_write_enable <= 0;
		load_complete <= 0;
	end
	else
	begin
		case (current_state)
		0: begin
			// Initial state: begin sending welcome byte (0x64)
			byte_to_tx <= 8'h64;
			tx_byte_now <= 1;
			current_state <= 1;
		end
		1: begin
			// Initial state: end sending welcome byte and wait for input.
			tx_byte_now <= 0;
			current_state <= 2;
		end
		2: begin
			// MSB received; begin writing to RAM.
			ram_write_enable <= 0;
			if (byte_received_flag && baud_clk)
			begin
				ram_data_out[15:8] <= byte_received;
				current_state <= 3;
			end
		end
		3: begin
			// LSB received; commit write to RAM.
			if (byte_received_flag && baud_clk)
			begin
				ram_data_out[7:0] <= byte_received;
				ram_write_enable <= 1;
				current_state <= 4;
			end
		end
		4: begin
			// Continue committing write to RAM.
			if (~byte_received_flag)
				current_state <= 5;
		end
		5: begin
			// End writing to RAM, increment address, move to next state depending on address.
			ram_write_enable <= 0;
			ram_addr_out <= ram_addr_out + 1;
			if (ram_addr_out < MAX_LOAD_ADDRESS)
			begin
				current_state <= 2;
			end
			else
			begin
				current_state <= 6;
			end
		end
		6: begin
			// End program loading and begin startup.
			load_complete <= 1;
		end
		default: begin
			// Should not reach here.
			current_state <= 0;
		end
		endcase
	end
end

endmodule