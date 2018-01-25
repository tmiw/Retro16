module vga_pixel_gen (
	pixel_clk,
	data_reset,
	pixel_col,
	pixel_row,
	vga_r,
	vga_g,
	vga_b
);

input wire pixel_clk;
input wire data_reset;
input [15:0] pixel_col;
input [15:0] pixel_row;
output wire vga_r;
output wire vga_g;
output wire vga_b;

reg [15:0] ascii;
reg [15:0] memory_offset;
wire pixel_en;

assign memory_offset = data_reset ? 16'd0 : (pixel_col / 16'd8) + ((pixel_row / 16'd16) * 16'd80);

always @(posedge pixel_clk)
begin
	case (memory_offset)
	160: ascii <= 16'h0148; // H
	161: ascii <= 16'h0265; // e
	162: ascii <= 16'h036c; // l
	163: ascii <= 16'h046c; // l
	164: ascii <= 16'h056f; // o
	165: ascii <= 16'h0720; // (space)
	166: ascii <= 16'h0677; // w
	167: ascii <= 16'h076f; // o
	168: ascii <= 16'h0172; // r
	169: ascii <= 16'h026c; // l
	170: ascii <= 16'h0364; // d
	171: ascii <= 16'h0421; // !
	default: ascii <= 0;
	endcase
	
	vga_r <= data_reset ? 1'b0 : (!pixel_en ? ascii[14] : ascii[10]);
	vga_g <= data_reset ? 1'b0 : (!pixel_en ? ascii[13] : ascii[9]);
	vga_b <= data_reset ? 1'b0 : (!pixel_en ? ascii[12] : ascii[8]);
end

pc_vga_8x16 char_rom(data_reset ? 0 : pixel_clk, pixel_col[2:0], pixel_row[3:0], ascii[7:0], pixel_en);

endmodule