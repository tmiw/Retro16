module control_unit(
	clk,
	rst
);

input clk;
input rst;

reg [2:0] left_register_num;
reg [2:0] right_register_num;
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
reg [2:0] alu_operation;
wire [15:0] alu_result;

alu processor_alu(
	alu_operand1,
	alu_operand2,
	alu_operation,
	alu_result
);

reg [15:0] instruction_reg;
reg [2:0] current_state;

always @(posedge clk)
begin
	if (rst)
	begin
		write_register_num <= 6;
		write_register_in <= 16'h0100; // PC on boot = 256
		reg_write_en <= 0;
		current_state <= 0;
	end
	else
	begin
		case (current_state)
		0: begin
			// Fetch
			reg_write_en <= 0;
			current_state <= current_state + 1;
		end
		1: begin
			// Decode
			current_state <= current_state + 1;
		end
		2: begin
			// Execute
			current_state <= current_state + 1;
		end
		3: begin
			// Memory Access
			current_state <= current_state + 1;
		end
		4: begin
			// Writeback (to registers)
			current_state <= 0;
		end
		default: current_state <= 0;
		endcase
	end
end

endmodule