`timescale 1ns/1ps
module register_file(
	clk,
	left_register_num,
	left_register_out,
	right_register_num,
	right_register_out,
	pc_register_out,
	cond_bit_out,
	write_register_num,
	write_register_in,
	write_en
);

input clk;
input [2:0] left_register_num;
input [2:0] right_register_num;
input [2:0] write_register_num;
input [15:0] write_register_in;
input write_en;
output reg [15:0] left_register_out = 0;
output reg [15:0] right_register_out = 0;
output reg [2:0] cond_bit_out = 0;
output reg [15:0] pc_register_out = 0;

reg [15:0] reg_data[0:7];
reg [2:0] cond_bits;

always @(*)
begin
	if (left_register_num == 0)
		left_register_out <= 0;
	else
		left_register_out <= reg_data[left_register_num];
		
	if (right_register_num == 0)
		right_register_out <= 0;
	else
		right_register_out <= reg_data[right_register_num];
		
	cond_bit_out <= cond_bits;
	pc_register_out <= reg_data[6];
end

always @(posedge clk)
begin
	if (write_en)
	begin
		if (write_register_num > 0)
		begin
			reg_data[write_register_num] <= write_register_in;
		end
		
		cond_bits <= {write_register_in == 0, write_register_in > 0, write_register_in[15]};
	end
end

endmodule