`timescale 1ns/1ps
module alu(
	clk,
	operand1,
	operand2,
	operation,
	result
);

input clk;
input [15:0] operand1;
input [15:0] operand2;
input [2:0] operation;
output reg [15:0] result;

reg [15:0] tempval;

always @(operand1 or operand2 or operation)
begin
	case (operation)
		3'b000:	
		begin
			if (operand2[15] == 1)
			begin
				tempval <= ~operand2 + 16'b1;
				result <= operand1 >> tempval[3:0];
			end
			else
			begin
				tempval <= 0;
				result <= operand1 << operand2[3:0];
			end
		end
		3'b100:
		begin
			result <= operand1 + operand2;
			tempval <= 0;
		end
		3'b101:	
		begin
			result <= operand1 & operand2;
			tempval <= 0;
		end
		3'b110:	
		begin
			result <= operand1 | operand2;
			tempval <= 0;
		end
		3'b111:	
		begin
			result <= ~operand1;
			tempval <= 0;
		end
		default:
		begin
			result <= 0;
			tempval <= 0;
		end
	endcase
end

endmodule