`timescale 1ns/1ps
module control_unit(
	clk,
	rst,
	ram_address_in,
	ram_data_in,
	ram_data_out,
	ram_read_en,
	ram_write_en,
	interrupt_en,
	interrupt_num,
	interrupt_ack
);

input clk;
input rst;
output reg [15:0] ram_address_in;
input [15:0] ram_data_in;
output reg [15:0] ram_data_out;
output reg ram_read_en;
output reg ram_write_en;
input interrupt_en;
input [2:0] interrupt_num;
output reg interrupt_ack;

wire [2:0] left_register_num;
wire [2:0] right_register_num;
reg [2:0] write_register_num;
wire [15:0] left_register_out;
wire [15:0] right_register_out;
wire [15:0] pc_register_out;
reg [15:0] write_register_in;
reg [15:0] pc_register_in;
wire [2:0] cond_bit_out;
reg reg_write_en;
reg pc_write_en;
reg active_bank;

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
	reg_write_en,
	active_bank,
	pc_register_in,
	pc_write_en
);

reg [15:0] alu_operand1;
reg [15:0] alu_operand2;
wire [2:0] alu_operation;
wire [15:0] alu_result;

wire [15:0] alu_offset;
wire ram_should_write;
wire ram_should_read;
wire [2:0] dest_reg;
reg [15:0] instruction_reg = 0;
reg [2:0] current_state = 0;
wire should_interrupt_ack;

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
	ram_should_write,
	should_interrupt_ack
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
		pc_register_in <= 16'h0100; // PC on boot = 256
		pc_write_en <= 1;
		active_bank <= 0; // TODO: link to interrupt controller
		current_state <= 0;
		interrupt_ack <= 0;
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
			interrupt_ack <= 0;
			pc_write_en <= 0;
			current_state <= current_state + 3'b1;
		end
		1: begin
			// Decode
			ram_read_en <= 0;
			ram_write_en <= 0;
			instruction_reg <= ram_data_in;
			current_state <= current_state + 3'b1;
		end
		2: begin
			// Execute
			alu_operand1 <= left_register_out;
			if (ram_should_write || ram_should_read)
				alu_operand2 <= alu_offset;
			else
				alu_operand2 <= right_register_num == 0 ? alu_offset : right_register_out;
			current_state <= current_state + 3'b1;
		end
		3: begin
			// Memory Access
			if (ram_should_read)
			begin
				ram_read_en <= 1;
				ram_write_en <= 0;
				ram_address_in <= alu_result;
			end
			else if (ram_should_write)
			begin
				ram_read_en <= 0;
				ram_write_en <= 1;
				ram_address_in <= alu_result;
				write_register_num <= dest_reg;
				ram_data_out <= right_register_out;
			end
			current_state <= current_state + 3'b1;
		end
		4: begin
			// Writeback (to registers)
			if (!ram_should_write)
			begin
				reg_write_en <= 1;
				write_register_num <= dest_reg;
				if (ram_should_read)
					write_register_in <= ram_data_in;
				else
					write_register_in <= alu_result;
			end
			ram_read_en <= 0;
			ram_write_en <= 0;
			current_state <= current_state + 3'b1;
			interrupt_ack <= should_interrupt_ack;
		end
		5: begin
			// PC increment (if necessary)
			if (dest_reg != 6)
			begin
				pc_register_in <= pc_register_out + 1;
				pc_write_en <= 1;
			end
			current_state <= current_state + 3'b1;
		end
		6: begin
			// Interrupt handling, if needed
			if (!active_bank && interrupt_en)
			begin
				// PC = 0x100 - interrupt number.
				// Expected to be unconditional jump to actual handler at address.
				active_bank <= 1;
				pc_register_in <= 16'h0100 - interrupt_num;
				pc_write_en <= 1;
			end
			else if (active_bank && interrupt_ack)
			begin
				// Switch back to bank 0, e.g. normal mode.
				active_bank <= 0;
				reg_write_en <= 0;
				pc_write_en <= 0;
			end
			else
				pc_write_en <= 0;
			current_state <= current_state + 3'b1;
		end
		default: begin
			// No-op so that everything stabilizes.
			pc_write_en <= 0;
			current_state <= current_state + 3'b1;
		end
		endcase
	end
end

endmodule