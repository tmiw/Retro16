module alu(
	operand1,
	operand2,
	operation,
	result
);

input operand1[15:0];
input operand2[15:0];
input operation[1:0];
output result[15:0];

always @(operand1 or operand2 or operation)
begin
	case (operation)
		2'b00:	result <= operand1 + operand2;
		2'b01:	result <= operand1 & operand2;
		2'b10:	result <= operand1 | operand2;
		2'b11:	result <= ~operand1;
	endcase
end

endmodule