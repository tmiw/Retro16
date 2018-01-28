module f64 (
    clk,
	 rst,
	 vga_hsync,
	 vga_vsync,
	 vga_r,
	 vga_g,
	 vga_b
);

input wire clk;
input wire rst;
output wire vga_hsync;
output wire vga_vsync;
output wire vga_r;
output wire vga_g;
output wire vga_b;

// Assert reset for ~8 clock cycles before enabling display.
reg [2:0] reset_ctr = 0;
reg initial_rst = 1;
always @(posedge clk)
begin
	reset_ctr <= reset_ctr + 1'b1;
	if (reset_ctr == 0)
		initial_rst = 0;
end

vga_display display(clk, initial_rst || ~rst, vga_hsync, vga_vsync, vga_r, vga_g, vga_b);

endmodule