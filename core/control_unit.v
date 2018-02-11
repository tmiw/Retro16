module control_unit(
	clk,
	rst,
	ram_address_in,
	ram_data_in,
	ram_data_out,
	ram_read_en,
	ram_write_en
);

input clk;
input rst;
output reg [15:0] ram_address_in;
input [15:0] ram_data_in;
output reg [15:0] ram_data_out;
output reg ram_read_en;
output reg ram_write_en;

wire [2:0] left_register_num;
wire [2:0] right_register_num;
reg [2:0] write_register_num;
wire [15:0] left_register_out;
wire [15:0] right_register_out;
wire [15:0] pc_register_out;
reg [15:0] write_register_in;
wire [2:0] cond_bit_out;
reg reg_write_en;

register_file regs(
	clk,
	left_register_num,
	left_register_out,
	right_register_num,
	right_register_out,
	pc_register_out,
	cond_bit_out,
	write_register_num,
	write_register_in,
	reg_write_en
);

reg [15:0] alu_operand1;
reg [15:0] alu_operand2;
wire [2:0] alu_operation;
wire [15:0] alu_result;

wire [15:0] alu_offset;
wire ram_should_write;
wire ram_should_read;
wire [2:0] dest_reg;
reg [15:0] instruction_reg;
reg [2:0] current_state;

decoder instruction_decoder(
	clk,
	instruction_reg,
	cond_bit_out,
	dest_reg,
	left_register_num,
	right_register_num,
	alu_offset,
	alu_operation,
	ram_should_read,
	ram_should_write
);

alu processor_alu(
	clk,
	alu_operand1,
	alu_operand2,
	alu_operation,
	alu_result
);

always @(posedge clk)
begin
	if (rst)
	begin
		write_register_num <= 6;
		write_register_in <= 16'h0100; // PC on boot = 256
		reg_write_en <= 1;
		current_state <= 0;
	end
	else
	begin
		case (current_state)
		0: begin
			// Fetch instruction into IR.
			reg_write_en <= 0;
			ram_address_in <= pc_register_out;
			ram_read_en <= 1;
			ram_write_en <= 0;
			instruction_reg <= ram_data_in;
			current_state <= current_state + 1;
		end
		1: begin
			// Decode
			ram_read_en <= 0;
			ram_write_en <= 0;
			alu_operand1 <= left_register_out;
			alu_operand2 <= right_register_num == 0 ? alu_offset : right_register_out;
			current_state <= current_state + 1;
		end
		2: begin
			// Execute
			current_state <= current_state + 1;
		end
		3: begin
			// Memory Access
			if (ram_should_write || ram_should_read)
			begin
				ram_read_en <= ram_should_read;
				ram_write_en <= ram_should_write;
				ram_address_in <= alu_result;
				ram_data_out <= write_register_in;
			end
			current_state <= current_state + 1;
		end
		4: begin
			// Writeback (to registers)
			if (!ram_should_write)
			begin
				reg_write_en <= 1;
				write_register_num <= dest_reg;
			end
			ram_read_en <= 0;
			ram_write_en <= 0;
			current_state <= 0;
		end
		default: current_state <= 0;
		endcase
	end
end

endmodule