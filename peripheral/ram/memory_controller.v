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
	sram_we_inv
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
			current_byte <= current_byte + 1;
		end
	else if (write_en)
	begin
		if (address_in >= 16'hC000)
		begin
			// I/O area: 0xC000-0xFFFF
		end
		else
		begin
			sram_addr <= {4'b0, address_in, current_byte};
			sram_ce_inv <= 0;
			sram_oe_inv <= 1;
			sram_we_inv <= 0;
			if (current_byte)
				sram_data_out <= data_in[15:8];
			else
				sram_data_out <= data_in[15:8];
			current_byte <= current_byte + 1;
		end
	end
	else 
	begin
		current_byte <= 0;
		sram_ce_inv <= 1;
		sram_oe_inv <= 1;
		sram_we_inv <= 1;
	end
end

endmodule