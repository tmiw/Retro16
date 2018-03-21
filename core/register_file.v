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
	write_en,
	active_bank,
	pc_register_in,
	pc_write_en,
);

input clk;
input [2:0] left_register_num;
input [2:0] right_register_num;
input [2:0] write_register_num;
input [15:0] write_register_in;
input [15:0] pc_register_in;
input write_en;
input pc_write_en;
input active_bank;
output reg [15:0] left_register_out = 0;
output reg [15:0] right_register_out = 0;
output reg [2:0] cond_bit_out = 0;
output reg [15:0] pc_register_out = 0;

reg [15:0] reg_data[0:1][0:15];
reg [2:0] cond_bits;

reg [4:0] i, j;

initial
begin
	for (i = 0; i < 2; i = i + 1)
	begin
		for (j = 0; j < 16; j = j + 1)
		begin
			reg_data[i][j] = 0;
		end
	end
end

always @(*)
begin
	if (left_register_num == 0)
		left_register_out <= 0;
	else
		left_register_out <= 
			(write_en && write_register_num == left_register_num) ? 
			write_register_in : 
			reg_data[active_bank][left_register_num];
		
	if (right_register_num == 0)
		right_register_out <= 0;
	else
		right_register_out <= 
			(write_en && write_register_num == right_register_num) ?
			write_register_in :
			reg_data[active_bank][right_register_num];
		
	cond_bit_out <= cond_bits;
	pc_register_out <= pc_write_en ? pc_register_in : 
		(write_en && write_register_num == 6 ? write_register_in : reg_data[active_bank][6]);
end

always @(posedge clk)
begin
	if (write_en)
	begin
		if (write_register_num > 0)
		begin
			reg_data[active_bank][write_register_num] <= write_register_in;
		end
		
		cond_bits <= {
			write_register_in == 0, 
			~write_register_in[15] && write_register_in[14:0] > 0, 
			write_register_in[15]};
	end
	
	if (pc_write_en)
	begin
		reg_data[active_bank][6] <= pc_register_in;
	end
end

endmodule