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
	 rs232_tx,
	 rs232_rx
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
input rs232_rx;

reg pixel_clk = 0;
wire global_clk;
reg half_pixel_clk = 0;
reg core_clk = 0;

// For asserting reset on the core while the loader's operating.
wire initial_rst;

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
	
// The VGA display, which shows the output of our programs.
wire [11:0] video_ram_addr;
wire [15:0] video_ram_data;
wire video_ram_we;

vga_display display(
	global_clk, pixel_clk, ~initial_rst || rst, 
	vga_hsync, vga_vsync, vga_r, vga_g, vga_b, 
	video_ram_addr, video_ram_data, video_ram_we);

// Helper wires to allow for multiplexing RAM between the loader and core.
wire [15:0] ram_address_in;
wire [15:0] ram_data_in;
wire [15:0] ram_data_out;
wire ram_read_en;
wire ram_write_en;

wire [15:0] loader_ram_address_in;
wire [15:0] loader_ram_data_out;
wire loader_ram_write_en;

wire [15:0] core_ram_address_in;
wire [15:0] core_ram_data_out;
wire core_ram_write_en;

assign ram_address_in = ~initial_rst ? loader_ram_address_in : core_ram_address_in;
assign ram_data_out = ~initial_rst ? loader_ram_data_out : core_ram_data_out;
assign ram_write_en = ~initial_rst ? loader_ram_write_en : core_ram_write_en;

// The main CPU core. 
control_unit main_cpu(
	core_clk, 
	~initial_rst || rst,
	core_ram_address_in,
	ram_data_in,
	core_ram_data_out,
	ram_read_en,
	core_ram_write_en);

// Proxy to the Papilio's SRAM chip and I/O peripherals.
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

// TBD: link to interrupt system
wire [7:0] decoded_key;
wire read_key;
ps2_keyboard keyboard(global_clk, ps2_clk1, ps2_dat1, decoded_key, read_key);

// Load program on initial boot by receiving a binary file containing
// the system's non-I/O RAM and committing it to SRAM. Once received,
// the system will enable the main core.
wire baud_clk;
wire baud_oversample_clk;
reg [31:0] second_ctr = 0;
reg [7:0] byte_to_tx = 0;
reg tx_byte_now;
wire byte_received_flag;
wire [7:0] byte_received;

program_loader loader(
	global_clk,
	core_clk,
	rst,
	loader_ram_address_in,
	loader_ram_data_out,
	loader_ram_write_en,
	rs232_tx,
	rs232_rx,
	initial_rst);

endmodule