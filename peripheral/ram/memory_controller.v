module memory_controller(
	clk,
	address_in,
	data_in,
	data_out,
	read_en,
	write_en,
	sram_addr,
	sram_data,
	sram_ce_inv,
	sram_oe_inv,
	sram_we_inv,
	video_ram_addr,
	video_ram_data,
	video_ram_we
);

input clk;
input [15:0] address_in;
input [15:0] data_in;
output reg [15:0] data_out;
input write_en;
input read_en;

output reg [20:0] sram_addr;
inout [7:0] sram_data;
output reg sram_ce_inv;
output reg sram_oe_inv;
output reg sram_we_inv;

output reg [11:0] video_ram_addr;
output reg [15:0] video_ram_data = 0;
output reg video_ram_we = 0;

reg [7:0] sram_data_out;
assign sram_data = !sram_oe_inv ? 8'bz : sram_data_out;

reg current_byte;

always @(posedge clk)
begin
	if (read_en)
	begin
		if (address_in >= 16'hC000)
		begin
			// I/O area: 0xC000-0xFFFF
			data_out <= 0;
		end
		else if (address_in <= 16'h0105)
		begin
			// Simple program ROM for testing
			// Should change the background color of character (0,0) and pause forever
			case (address_in)
			16'h0000: data_out <= 16'hF82F; // const: 0xF82F
			16'h0001: data_out <= 16'h8000; // const: 0x8000
			16'h0100: data_out <= 16'h4400; // ld r1, r0, 0
			16'h0101: data_out <= 16'h4800; // ld r2, r0, 1
			16'h0102: data_out <= 16'h2301; // add r3, r0, 1
			16'h0103: data_out <= 16'h0468; // lsh r4, r3, 8
			16'h0104: data_out <= 16'h6600; // st r1, r4, 0
			16'h0105: data_out <= 16'h8ffb; // bru 0x0100
			default: data_out <= 0;
			endcase
		end
		else
			sram_addr <= {4'b0, address_in, current_byte};
			sram_ce_inv <= 0;
			sram_oe_inv <= 0;
			sram_we_inv <= 1;
			if (current_byte)
				data_out[7:0] <= sram_data;
			else
				data_out[15:8] <= sram_data;
			current_byte <= current_byte + 1'b1;
		end
	else if (write_en)
	begin
		if (address_in >= 16'hC000)
		begin
			// I/O area: 0xC000-0xFFFF
			if (address_in >= 16'hF82F)
			begin
				// Video RAM
				video_ram_addr <= address_in - 16'hF82F;
				video_ram_data <= data_in;
				video_ram_we <= 1;
			end
			else
			begin
				video_ram_addr <= 0;
				video_ram_data <= 0;
				video_ram_we <= 0;
			end
		end
		else
		begin
			sram_addr <= {4'b0, address_in, current_byte};
			sram_ce_inv <= 0;
			sram_oe_inv <= 1;
			sram_we_inv <= 0;
			video_ram_addr <= 0;
			video_ram_data <= 0;
			video_ram_we <= 0;
			if (current_byte)
				sram_data_out <= data_in[15:8];
			else
				sram_data_out <= data_in[7:0];
			current_byte <= current_byte + 1'b1;
		end
	end
	else 
	begin
		current_byte <= 0;
		sram_addr <= 0;
		sram_ce_inv <= 1;
		sram_oe_inv <= 1;
		sram_we_inv <= 1;
	end
end

endmodule