module vga_sync (
	pixel_clk,
	rst,
	vga_hsync,
	vga_vsync,
	data_rst,
	pixel_row,
	pixel_col
);

parameter VISIBLE_WIDTH = 640;
parameter HORIZ_FP = 16;
parameter HSYNC_WIDTH = 96;
parameter HORIZ_BP = 48;
parameter VISIBLE_HEIGHT = 480;
parameter VERT_FP = 10;
parameter VSYNC_WIDTH = 5;
parameter VERT_BP = 30;

input wire pixel_clk;
input wire rst;
output reg vga_hsync = 1'b0;
output reg vga_vsync = 1'b0;
output reg data_rst = 1'b0;
output reg [15:0] pixel_row = 16'b0;
output reg [15:0] pixel_col = 16'b0;

wire hsync_on;
wire vsync_on;

assign hsync_on = pixel_col == (VISIBLE_WIDTH + HORIZ_FP);

always @(posedge pixel_clk or posedge rst)
begin
	if (rst)
		pixel_col <= 16'b0;
	else if (pixel_col < (VISIBLE_WIDTH + HORIZ_FP + HSYNC_WIDTH + HORIZ_BP))
		pixel_col <= pixel_col + 16'b1;
	else
		pixel_col <= 16'b0;
end

always @(posedge pixel_clk or posedge rst)
begin
	if (rst)
		pixel_row <= 16'b0;
	else if (hsync_on)
	begin
		if (pixel_row < (VISIBLE_HEIGHT + VERT_FP + VSYNC_WIDTH + VERT_BP))
			pixel_row <= pixel_row + 16'b1;
		else
			pixel_row <= 16'b0;
	end
	else
		pixel_row <= pixel_row;
end

always @(posedge pixel_clk or posedge rst)
begin
	if (rst)
		vga_hsync <= 1'b1;
	else if (pixel_col >= (VISIBLE_WIDTH + HORIZ_FP) && pixel_col < (VISIBLE_WIDTH + HORIZ_FP + HSYNC_WIDTH))
		vga_hsync <= 1'b0;
	else
		vga_hsync <= 1'b1;
end

always @(posedge pixel_clk or posedge rst)
begin
	if (rst)
		vga_vsync <= 1'b1;
	else if (pixel_row >= (VISIBLE_HEIGHT + VERT_FP) && pixel_row < (VISIBLE_HEIGHT + VERT_FP + VSYNC_WIDTH))
		vga_vsync <= 1'b0;
	else
		vga_vsync <= 1'b1;
end

always @(posedge pixel_clk)
begin
	data_rst <= rst || (pixel_col >= VISIBLE_WIDTH || pixel_row >= VISIBLE_HEIGHT);
end

endmodule