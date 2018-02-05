module f64 (
    clk,
	 rst,
	 vga_hsync,
	 vga_vsync,
	 vga_r,
	 vga_g,
	 vga_b
);

input clk;
input wire rst;
output wire vga_hsync;
output wire vga_vsync;
output wire [3:0] vga_r;
output wire [3:0] vga_g;
output wire [3:0] vga_b;

reg pixel_clk;
wire global_clk;

// Assert reset for ~8 clock cycles before enabling display.
// Also, temporarily fill video RAM with hello message.
reg initial_rst = 1;
reg [11:0] video_ram_addr = 0;
reg [15:0] video_ram_data = 0;
reg video_ram_we = 0;
always @(posedge global_clk)
begin
	video_ram_addr <= video_ram_addr + 11'd1;
	if (video_ram_addr < 80*25)
	begin
		case (video_ram_addr)
		0:	video_ram_data <= 16'h0748; // H
		1: video_ram_data <= 16'h0765; // e
		2: video_ram_data <= 16'h076c; // l
		3: video_ram_data <= 16'h076c; // l
		4: video_ram_data <= 16'h076f; // o
		default: video_ram_data <= 16'h0700;
		endcase
		video_ram_we <= initial_rst;
	end
	else
		video_ram_addr <= 0;
		
	if (initial_rst && video_ram_addr >= 8)
	begin
		initial_rst <= 0;
	end
end

// Papilio Duo has a 32MHz clock. This needs to be upconverted
// to 50MHz by use of a PLL in order to drive the VGA display
// and other peripherals.
f64_clk_gen clock_generator(clk, global_clk, rst);

// Assumption: 50MHz global clock. Dividing by 4 gives 25MHz,
// which is the desired pixel clock for VGA 640x480@60Hz.
always @(posedge global_clk)
	pixel_clk <= pixel_clk + 1'b1;

vga_display display(global_clk, pixel_clk, initial_rst || rst, vga_hsync, vga_vsync, vga_r, vga_g, vga_b, video_ram_addr, video_ram_data, video_ram_we);

endmodule