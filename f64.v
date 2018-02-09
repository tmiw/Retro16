module f64 (
    clk,
	 rst,
	 vga_hsync,
	 vga_vsync,
	 vga_r,
	 vga_g,
	 vga_b,
	 ps2_dat1,
	 ps2_clk1
);

input clk;
input wire rst;
inout ps2_dat1;
inout ps2_clk1;
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
reg [15:0] ascii_chars = 16'h3030;

always @(posedge global_clk)
begin
	if (video_ram_addr < 80*25)
	begin
		case (video_ram_addr)
		0:	video_ram_data <= 16'h0748; // H
		1: video_ram_data <= 16'h0765; // e
		2: video_ram_data <= 16'h076c; // l
		3: video_ram_data <= 16'h076c; // l
		4: video_ram_data <= 16'h076f; // o
		
		// For keyboard testing
		8: video_ram_data <= {8'h07, ascii_chars[15:8]};
		9: video_ram_data <= {8'h07, ascii_chars[7:0]};
		default: video_ram_data <= 16'h0700;
		endcase
		video_ram_we <= 1; //(video_ram_addr >= 0 && video_ram_addr < 5) || (video_ram_addr >= 160 && video_ram_addr < 162);
		video_ram_addr <= video_ram_addr + 11'd1;
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

// Assumption: 50MHz global clock. Dividing by 2 gives 25MHz,
// which is the desired pixel clock for VGA 640x480@60Hz.
always @(posedge global_clk)
	pixel_clk <= pixel_clk + 1'b1;

vga_display display(global_clk, pixel_clk, initial_rst || rst, vga_hsync, vga_vsync, vga_r, vga_g, vga_b, video_ram_addr, video_ram_data, video_ram_we);

wire [7:0] decoded_key;
wire read_key;
ps2_keyboard keyboard(global_clk, ps2_clk1, ps2_dat1, decoded_key, read_key);

always @(posedge read_key)
begin
	if (decoded_key[7:4] < 4'ha)
		ascii_chars[15:8] <= 8'h30 + {4'b0, decoded_key[7:4]};
	else
		ascii_chars[15:8] <= 8'h37 + {4'b0, decoded_key[7:4]};
		
	if (decoded_key[3:0] < 4'ha)
		ascii_chars[7:0] <= 8'h30 + {4'b0, decoded_key[3:0]};
	else
		ascii_chars[7:0] <= 8'h37 + {4'b0, decoded_key[3:0]};
end

endmodule