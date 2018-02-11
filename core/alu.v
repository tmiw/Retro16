module alu(
	operand1,
	operand2,
	operation,
	result
);

input [15:0] operand1;
input [15:0] operand2;
input [2:0] operation;
output reg [15:0] result;

always @(operand1 or operand2 or operation)
begin
	case (operation)
		3'b000:	
		begin
			if (operand2[15] == 1)
			begin
				result <= operand1 >> (~operand2 + 1);
			end
			else
				result <= operand1 << operand2;
			end
		3'b100:	
			result <= operand1 + operand2;
		3'b101:	
			result <= operand1 & operand2;
		3'b110:	
			result <= operand1 | operand2;
		3'b111:	
			result <= ~operand1;
		default:
			result <= 0;
	endcase
end

endmodule