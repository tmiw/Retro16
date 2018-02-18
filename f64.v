`timescale 1ns/1ps
module f64 (
    clk,
	 rst,
	 vga_hsync,
	 vga_vsync,
	 vga_r,
	 vga_g,
	 vga_b,
	 ps2_dat1,
	 ps2_clk1,
	 sram_addr,
	 sram_data,
	 sram_ce,
	 sram_oe,
	 sram_we,
	 rs232_tx
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
output wire [20:0] sram_addr;
inout [7:0] sram_data;
output sram_ce;
output sram_oe;
output sram_we;
output rs232_tx;

reg pixel_clk = 0;
wire global_clk;
reg half_pixel_clk = 0;
reg core_clk = 0;

// Assert reset for ~8 clock cycles before enabling display.
// Also, temporarily fill video RAM with hello message.
reg initial_rst = 1;
wire [11:0] video_ram_addr;
wire [15:0] video_ram_data;
wire video_ram_we;
reg [4:0] reset_ctr = 0;
reg [15:0] ascii_chars = 16'h3030;

always @(posedge core_clk)
begin
	/*if (video_ram_addr < 80*25)
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
		video_ram_addr <= 0;*/
	
	reset_ctr <= reset_ctr + 1;
	if (initial_rst && reset_ctr >= 8)
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
// Core clock is 6.25MHz (50MHz/8), may potentially be able to
// run faster depending on testing.
always @(posedge global_clk)
	pixel_clk <= pixel_clk + 1'b1;

always @(posedge pixel_clk)
	half_pixel_clk <= half_pixel_clk + 1'b1;

always @(posedge half_pixel_clk)
	core_clk <= core_clk + 1'b1;
	
vga_display display(global_clk, pixel_clk, initial_rst || rst, vga_hsync, vga_vsync, vga_r, vga_g, vga_b, video_ram_addr, video_ram_data, video_ram_we);

wire [15:0] ram_address_in;
wire [15:0] ram_data_in;
wire [15:0] ram_data_out;
wire ram_read_en;
wire ram_write_en;

control_unit main_cpu(
	core_clk, 
	initial_rst || rst,
	ram_address_in,
	ram_data_in,
	ram_data_out,
	ram_read_en,
	ram_write_en);

memory_controller ram(
	global_clk,
	ram_address_in,
	ram_data_out,
	ram_data_in,
	ram_read_en,
	ram_write_en,
	sram_addr,
	sram_data,
	sram_ce,
	sram_oe,
	sram_we,
	video_ram_addr,
	video_ram_data,
	video_ram_we
);

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

// Print "Y" once a second. This is to test the RS-232 tx related modules.
wire baud_clk;
reg [31:0] second_ctr = 0;
reg [7:0] byte_to_tx = 8'h59;
wire tx_byte_now;

baud_generator rs232_baud(global_clk, baud_clk);
byte_transmitter rs232_transmitter(global_clk, baud_clk, byte_to_tx, tx_byte_now, rs232_tx);

assign tx_byte_now = (second_ctr == 0);

always @(posedge baud_clk)
begin
	if (second_ctr == 0)
		second_ctr <= 115200;
	else
		second_ctr <= second_ctr - 1;
end

endmodule