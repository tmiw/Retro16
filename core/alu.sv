module alu(
	operand1,
	operand2,
	operation,
	result
);

input operand1[15:0];
input operand2[15:0];
input operation[2:0];
output result[15:0];

always @(operand1 or operand2 or operation)
begin
	case (operation)
		3'b000:	
			result <= operand1 << operand2;
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