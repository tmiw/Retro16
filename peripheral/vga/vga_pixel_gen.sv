module vga_pixel_gen (
	pixel_clk,
	data_reset,
	ram_addr,
	ram_contents,
	pixel_col,
	pixel_row,
	vga_r,
	vga_g,
	vga_b
);

input wire pixel_clk;
input reg data_reset;
output reg [11:0] ram_addr;
input reg [15:0] ram_contents;
input [15:0] pixel_col;
input [15:0] pixel_row;
output reg vga_r;
output reg vga_g;
output reg vga_b;

wire [7:0] pixel_en;
wire ram_addr_past_80x25;
reg data_reset_sync;

pc_vga_font_rom char_rom(pixel_clk, ram_contents[7:0], pixel_row[3:0], pixel_en);
assign ram_addr_past_80x25 = pixel_row >= 25;

reg [15:0] rom_output_odd;
reg [15:0] rom_output_even;

always @(posedge pixel_clk)
begin
	// Halfway through rendering the current character, we want to start preloading
	// the next character's row of pixels from ROM. This preloaded data should go
	// into a register that's not currently being used for rendering. Once we cross
	// over into the next character, we swap the buffers for the next round.
	if (pixel_col[2] == 1'b1)
	begin
		ram_addr <= data_reset ? 12'd0 : 1 + (pixel_col / 16'd8) + ((pixel_row / 16'd16) * 16'd80);
		if (((pixel_col + 4) / 16) & 1'b1)
		begin
			rom_output_even[15:8] <= ram_contents[15:8];
			rom_output_even[7:0] <= pixel_en;
		end
		else
		begin
			rom_output_odd[15:8] <= ram_contents[15:8];
			rom_output_odd[7:0] <= pixel_en;
		end
	end
	
	if ((pixel_col / 16) & 1'b1)
	begin
		vga_r <= data_reset || ram_addr_past_80x25 ? 1'b0 : (!rom_output_even[pixel_col[2:0]] ? rom_output_even[14] : rom_output_even[10]);
		vga_g <= data_reset || ram_addr_past_80x25 ? 1'b0 : (!rom_output_even[pixel_col[2:0]] ? rom_output_even[13] : rom_output_even[9]);
		vga_b <= data_reset || ram_addr_past_80x25 ? 1'b0 : (!rom_output_even[pixel_col[2:0]] ? rom_output_even[12] : rom_output_even[8]);
	end
	else
		begin
		vga_r <= data_reset || ram_addr_past_80x25 ? 1'b0 : (!rom_output_odd[pixel_col[2:0]] ? rom_output_odd[14] : rom_output_odd[10]);
		vga_g <= data_reset || ram_addr_past_80x25 ? 1'b0 : (!rom_output_odd[pixel_col[2:0]] ? rom_output_odd[13] : rom_output_odd[9]);
		vga_b <= data_reset || ram_addr_past_80x25 ? 1'b0 : (!rom_output_odd[pixel_col[2:0]] ? rom_output_odd[12] : rom_output_odd[8]);
	end
end

endmodule