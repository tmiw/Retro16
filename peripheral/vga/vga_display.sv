module vga_display(
	clk,
	rst,
	vga_hsync,
	vga_vsync,
	vga_r,
	vga_g,
	vga_b
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
input wire rst;
output wire vga_hsync;
output wire vga_vsync;
output wire vga_r;
output wire vga_g;
output wire vga_b;

// Effective 25MHz clock. Adjust as appropriate for other resolutions.
reg pixel_clk;
always @(posedge clk or posedge rst)
begin
	if (rst)
		pixel_clk <= 0;
	else
		pixel_clk <= pixel_clk + 1'b1;
end

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

// Pixel generation is at global clock rate (not pixel clock) due to fuzziness/misrendered 
// characters otherwise.
// TODO: determine if use of pixel clock is possible.
vga_pixel_gen pixel_generator(clk, data_reset, pixel_col, pixel_row, vga_r, vga_g, vga_b);
endmodule