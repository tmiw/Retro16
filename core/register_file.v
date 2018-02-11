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
output reg [15:0] left_register_out;
output reg [15:0] right_register_out;
output reg [2:0] cond_bit_out;
output reg [15:0] pc_register_out;

reg [15:0] reg_data[0:7];
reg [15:0] tmp_write_in;
reg [2:0] cond_bits;

always @(posedge clk)
begin
	if (write_register_num == 0)
		tmp_write_in <= 0;
	else
		tmp_write_in <= write_register_in;
		
	if (write_en)
	begin
		reg_data[write_register_num] <= tmp_write_in;
		cond_bits <= {tmp_write_in == 0, tmp_write_in > 0, tmp_write_in < 0};
	end
	
	left_register_out <= reg_data[left_register_num];
	right_register_out <= reg_data[right_register_num];
	cond_bit_out <= cond_bits;
	pc_register_out <= reg_data[6];
end

endmodule