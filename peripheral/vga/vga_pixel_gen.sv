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
input wire data_reset;
output reg [11:0] ram_addr;
input reg [15:0] ram_contents;
input [15:0] pixel_col;
input [15:0] pixel_row;
output reg vga_r;
output reg vga_g;
output reg vga_b;

wire pixel_en;
wire ram_addr_past_80x25;

assign ram_addr = data_reset ? 12'd0 : (pixel_col / 12'd8) + ((pixel_row / 12'd16) * 12'd80);
assign ram_addr_past_80x25 = ram_addr > (80 * 25);

always @(posedge pixel_clk)
begin
	vga_r <= data_reset || ram_addr_past_80x25 ? 1'b0 : (!pixel_en ? ram_contents[14] : ram_contents[10]);
	vga_g <= data_reset || ram_addr_past_80x25 ? 1'b0 : (!pixel_en ? ram_contents[13] : ram_contents[9]);
	vga_b <= data_reset || ram_addr_past_80x25 ? 1'b0 : (!pixel_en ? ram_contents[12] : ram_contents[8]);
end

pc_vga_8x16 char_rom(data_reset ? 0 : pixel_clk, pixel_col[2:0], pixel_row[3:0], ram_contents[7:0], pixel_en);

endmodule