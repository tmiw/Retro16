module vga_display(
	clk,
	pixel_clk,
	rst,
	vga_hsync,
	vga_vsync,
	vga_r,
	vga_g,
	vga_b,
	video_ram_input_addr,
	video_ram_input_data,
	video_ram_we
);

localparam VGA_DISPLAY_VISIBLE_WIDTH = 640;
localparam VGA_DISPLAY_VISIBLE_HEIGHT = 480;
localparam VGA_DISPLAY_HORIZ_SYNC = 96;
localparam VGA_DISPLAY_HORIZ_FP = 16;
localparam VGA_DISPLAY_HORIZ_BP = 48;
localparam VGA_DISPLAY_VERT_SYNC = 5;
localparam VGA_DISPLAY_VERT_FP = 10;
localparam VGA_DISPLAY_VERT_BP = 30;
localparam VGA_DISPLAY_FIELD_WIDTH = VGA_DISPLAY_VISIBLE_WIDTH + VGA_DISPLAY_HORIZ_SYNC + VGA_DISPLAY_HORIZ_FP + VGA_DISPLAY_HORIZ_BP;
localparam VGA_DISPLAY_FIELD_HEIGHT = VGA_DISPLAY_VISIBLE_HEIGHT + VGA_DISPLAY_VERT_SYNC + VGA_DISPLAY_VERT_FP + VGA_DISPLAY_VERT_BP;

input wire clk;
input wire pixel_clk;
input wire rst;
output wire vga_hsync;
output wire vga_vsync;
output wire vga_r;
output wire vga_g;
output wire vga_b;
input reg [11:0] video_ram_input_addr;
input reg [15:0] video_ram_input_data;
input wire video_ram_we;

wire data_reset;
reg [15:0] pixel_row;
reg [15:0] pixel_col;

vga_sync #(
	.VISIBLE_WIDTH(VGA_DISPLAY_VISIBLE_WIDTH),
	.HORIZ_FP(VGA_DISPLAY_HORIZ_FP),
	.HSYNC_WIDTH(VGA_DISPLAY_HORIZ_SYNC),
	.HORIZ_BP(VGA_DISPLAY_HORIZ_BP),
	.VISIBLE_HEIGHT(VGA_DISPLAY_VISIBLE_HEIGHT),
	.VERT_FP(VGA_DISPLAY_VERT_FP),
	.VSYNC_WIDTH(VGA_DISPLAY_VERT_SYNC),
	.VERT_BP(VGA_DISPLAY_VERT_BP)
) sync_generator(pixel_clk, rst, vga_hsync, vga_vsync, data_reset, pixel_row, pixel_col);

reg [11:0] video_ram_address;
reg [15:0] video_ram_contents;
reg [15:0] tmp;

video_ram #(
	.DATA_WIDTH(16),
	.ADDR_WIDTH(11)
) video_framebuffer(video_ram_input_data, 0, video_ram_input_addr, video_ram_address, video_ram_we, 0, clk, clk, tmp, video_ram_contents);

vga_pixel_gen pixel_generator(pixel_clk, data_reset, video_ram_address, video_ram_contents, pixel_col, pixel_row, vga_r, vga_g, vga_b);

endmodule