module decoder(
	clk,
	instruction,
	cond_bits,
	destination_reg,
	first_reg,
	second_reg,
	offset,
	alu_op,
	ram_read,
	ram_write
);

input clk;
input [15:0] instruction;
input [2:0] cond_bits;
output reg [2:0] destination_reg;
output reg [2:0] first_reg;
output reg [2:0] second_reg;
output reg [15:0] offset;
output reg [2:0] alu_op;
output reg ram_read;
output reg ram_write;

always @(instruction or cond_bits)
begin
	if (instruction[15])
	begin
		// Branch
		destination_reg <= 6; // PC
		first_reg <= 6; // PC
		second_reg <= 0; // R0
		ram_read <= 0;
		ram_write <= 0;
		alu_op <= 3'b100; // Add
		case (instruction[14:12])
		3'b000:	begin
			// Branch Unconditional
			offset <= {{4{instruction[11]}}, instruction[11:0]};
		end
		3'b001:	begin
			// Branch Less Than
			if (cond_bits[0])
				offset <= {{4{instruction[11]}}, instruction[11:0]};
			else
				offset <= 1;
		end
		3'b010:	begin
			// Branch Greater Than
			if (cond_bits[1])
				offset <= {{4{instruction[11]}}, instruction[11:0]};
			else
				offset <= 1;
		end
		3'b100:	begin
			// Branch Zero
			if (cond_bits[2])
				offset <= {{4{instruction[11]}}, instruction[11:0]};
			else
				offset <= 1;
		end
		3'b101:	begin
			// Branch Less Or Equal
			if (cond_bits[0] || cond_bits[2])
				offset <= {{4{instruction[11]}}, instruction[11:0]};
			else
				offset <= 1;
		end
		3'b110:	begin
			// Branch Greater Or Equal
			if (cond_bits[1] || cond_bits[2])
				offset <= {{4{instruction[11]}}, instruction[11:0]};
			else
				offset <= 1;
		end
		default:	offset <= 1;
		endcase
	end
	else if (instruction[15:14] == 3'b01)
	begin
		// Load/Store
		destination_reg <= instruction[12:10];
		first_reg <= instruction[9:7];
		second_reg <= 0; // R0
		offset <= {{9{instruction[6]}}, instruction[6:0]};
		ram_read <= ~instruction[13];
		ram_write <= instruction[13];
		alu_op <= 3'b100; // Add
	end
	else if (instruction[15:11] == 5'b0)
	begin
		// Shift
		destination_reg <= instruction[10:8];
		first_reg <= instruction[7:5];
		second_reg <= 0; // R0
		offset <= {{11{instruction[4]}}, instruction[4:0]};
		alu_op <= 3'b000; // Shift
		ram_read <= 0;
		ram_write <= 0;
	end
	else if (instruction[15:11] == 5'b00001)
	begin
		// ALU, two regs
		destination_reg <= instruction[8:6];
		first_reg <= instruction[5:3];
		second_reg <= instruction[2:0];
		offset <= 0;
		alu_op <= {1'b1, instruction[10:9]};
		ram_read <= 0;
		ram_write <= 0;
	end
	else if (instruction[15:13] == 3'b001)
	begin
		// ALU, reg + offset
		destination_reg <= instruction[10:8];
		first_reg <= instruction[7:5];
		second_reg <= 0; // R0
		offset <= {{11{instruction[4]}}, instruction[4:0]};
		alu_op <= {1'b1, instruction[12:11]};
		ram_read <= 0;
		ram_write <= 0;
	end
	else
	begin
		// No-op
		destination_reg <= 0; // R0
		first_reg <= 0; // R0
		second_reg <= 0; // R0
		offset <= 0;
		alu_op <= 3'b100;
		ram_read <= 0;
		ram_write <= 0;
	end
end

endmodule