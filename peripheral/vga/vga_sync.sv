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
output wire vga_hsync;
output wire vga_vsync;
output wire data_rst;
output [15:0] pixel_row;
output [15:0] pixel_col;

reg [15:0] h_ctr = 16'b0;
reg [15:0] v_ctr = 16'b0;

always @(posedge pixel_clk or posedge rst)
begin
	if (rst)
	begin
		h_ctr <= 16'b0;
		v_ctr <= 16'b0;
	end
	else
	begin
		h_ctr <= (h_ctr + 16'b1) == (VISIBLE_WIDTH + HORIZ_FP + HSYNC_WIDTH + HORIZ_BP) ? 16'b0 : (h_ctr + 16'b1);
		if (h_ctr == 0)
			v_ctr <= (v_ctr + 16'b1) == (VISIBLE_HEIGHT + VERT_FP + VSYNC_WIDTH + VERT_BP) ? 16'b0 : (v_ctr + 16'b1);
	end
end

assign vga_hsync = (h_ctr >= (VISIBLE_WIDTH + HORIZ_FP) && h_ctr < (VISIBLE_WIDTH + HORIZ_FP + HSYNC_WIDTH)) ? 1'b0 : 1'b1;
assign vga_vsync = (v_ctr >= (VISIBLE_HEIGHT + VERT_FP) && v_ctr < (VISIBLE_HEIGHT + VERT_FP + VSYNC_WIDTH)) ? 1'b0 : 1'b1;
assign data_rst = rst || (h_ctr >= VISIBLE_WIDTH || v_ctr >= VISIBLE_HEIGHT);
assign pixel_col = h_ctr;
assign pixel_row = v_ctr;

endmodule