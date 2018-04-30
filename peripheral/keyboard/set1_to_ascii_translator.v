module set1_to_ascii_translator(
	set1_keycode,
	key_break_in,
	ascii_character
);

input [15:0] set1_keycode;
input key_break_in;
output reg [7:0] ascii_character;

reg caps_enabled;
reg shift_pressed;

assign use_uppercase = caps_enabled ^ shift_pressed;

always @(*)
begin
	case ({10'd0, set1_keycode[6:0]})
		16'h003A: begin
			// Caps Lock
			caps_enabled <= ~caps_enabled;
		end
		16'h002A, 16'h0036: begin
			// Left/Right Shift
			if (key_break_in)
				shift_pressed <= 0;
			else
				shift_pressed <= 1;
		end
		16'h0029: begin
			 if (~use_uppercase) ascii_character <= 16'h0060; // `
			 else ascii_character <= 16'h007e; // ~
		end
		16'h0002: begin
			 if (~use_uppercase) ascii_character <= 16'h0031; // 1
			 else ascii_character <= 16'h0021; // !
		end
		16'h0003: begin
			 if (~use_uppercase) ascii_character <= 16'h0032; // 2
			 else ascii_character <= 16'h0040; // @
		end
		16'h0004: begin
			 if (~use_uppercase) ascii_character <= 16'h0033; // 3
			 else ascii_character <= 16'h0023; // #
		end
		16'h0005: begin
			 if (~use_uppercase) ascii_character <= 16'h0034; // 4
			 else ascii_character <= 16'h0024; // $
		end
		16'h0006: begin
			 if (~use_uppercase) ascii_character <= 16'h0035; // 5
			 else ascii_character <= 16'h0025; // %
		end
		16'h0007: begin
			 if (~use_uppercase) ascii_character <= 16'h0036; // 6
			 else ascii_character <= 16'h005e; // ^
		end
		16'h0008: begin
			 if (~use_uppercase) ascii_character <= 16'h0037; // 7
			 else ascii_character <= 16'h0026; // &
		end
		16'h0009: begin
			 if (~use_uppercase) ascii_character <= 16'h0038; // 8
			 else ascii_character <= 16'h002a; // *
		end
		16'h000A: begin
			 if (~use_uppercase) ascii_character <= 16'h0039; // 9
			 else ascii_character <= 16'h0028; // (
		end
		16'h000B: begin
			 if (~use_uppercase) ascii_character <= 16'h0030; // 0
			 else ascii_character <= 16'h0029; // )
		end
		16'h000C: begin
			 if (~use_uppercase) ascii_character <= 16'h002d; // -
			 else ascii_character <= 16'h005f; // _
		end
		16'h000D: begin
			 if (~use_uppercase) ascii_character <= 16'h003d; // =
			 else ascii_character <= 16'h002b; // +
		end
		16'h0010: begin
			 if (~use_uppercase) ascii_character <= 16'h0071; // q
			 else ascii_character <= 16'h0051; // Q
		end
		16'h0011: begin
			 if (~use_uppercase) ascii_character <= 16'h0077; // w
			 else ascii_character <= 16'h0057; // W
		end
		16'h0012: begin
			 if (~use_uppercase) ascii_character <= 16'h0065; // e
			 else ascii_character <= 16'h0045; // E
		end
		16'h0013: begin
			 if (~use_uppercase) ascii_character <= 16'h0072; // r
			 else ascii_character <= 16'h0052; // R
		end
		16'h0014: begin
			 if (~use_uppercase) ascii_character <= 16'h0074; // t
			 else ascii_character <= 16'h0054; // T
		end
		16'h0015: begin
			 if (~use_uppercase) ascii_character <= 16'h0079; // y
			 else ascii_character <= 16'h0059; // Y
		end
		16'h0016: begin
			 if (~use_uppercase) ascii_character <= 16'h0075; // u
			 else ascii_character <= 16'h0055; // U
		end
		16'h0017: begin
			 if (~use_uppercase) ascii_character <= 16'h0069; // i
			 else ascii_character <= 16'h0049; // I
		end
		16'h0018: begin
			 if (~use_uppercase) ascii_character <= 16'h006f; // o
			 else ascii_character <= 16'h004f; // O
		end
		16'h0019: begin
			 if (~use_uppercase) ascii_character <= 16'h0070; // p
			 else ascii_character <= 16'h0050; // P
		end
		16'h001A: begin
			 if (~use_uppercase) ascii_character <= 16'h005b; // [
			 else ascii_character <= 16'h007b; // {
		end
		16'h001B: begin
			 if (~use_uppercase) ascii_character <= 16'h005d; // ]
			 else ascii_character <= 16'h007d; // }
		end
		16'h001E: begin
			 if (~use_uppercase) ascii_character <= 16'h0061; // a
			 else ascii_character <= 16'h0041; // A
		end
		16'h001F: begin
			 if (~use_uppercase) ascii_character <= 16'h0073; // s
			 else ascii_character <= 16'h0053; // S
		end
		16'h0020: begin
			 if (~use_uppercase) ascii_character <= 16'h0064; // d
			 else ascii_character <= 16'h0044; // D
		end
		16'h0021: begin
			 if (~use_uppercase) ascii_character <= 16'h0066; // f
			 else ascii_character <= 16'h0046; // F
		end
		16'h0022: begin
			 if (~use_uppercase) ascii_character <= 16'h0067; // g
			 else ascii_character <= 16'h0047; // G
		end
		16'h0023: begin
			 if (~use_uppercase) ascii_character <= 16'h0068; // h
			 else ascii_character <= 16'h0048; // H
		end
		16'h0024: begin
			 if (~use_uppercase) ascii_character <= 16'h006a; // j
			 else ascii_character <= 16'h004a; // J
		end
		16'h0025: begin
			 if (~use_uppercase) ascii_character <= 16'h006b; // k
			 else ascii_character <= 16'h004b; // K
		end
		16'h0026: begin
			 if (~use_uppercase) ascii_character <= 16'h006c; // l
			 else ascii_character <= 16'h004c; // L
		end
		16'h0027: begin
			 if (~use_uppercase) ascii_character <= 16'h003b; // ;
			 else ascii_character <= 16'h003a; // :
		end
		16'h0028: begin
			 if (~use_uppercase) ascii_character <= 16'h0027; // '
			 else ascii_character <= 16'h0022; // "
		end
		16'h002C: begin
			 if (~use_uppercase) ascii_character <= 16'h007a; // z
			 else ascii_character <= 16'h005a; // Z
		end
		16'h002D: begin
			 if (~use_uppercase) ascii_character <= 16'h0078; // x
			 else ascii_character <= 16'h0058; // X
		end
		16'h002E: begin
			 if (~use_uppercase) ascii_character <= 16'h0063; // c
			 else ascii_character <= 16'h0043; // C
		end
		16'h002F: begin
			 if (~use_uppercase) ascii_character <= 16'h0076; // v
			 else ascii_character <= 16'h0056; // V
		end
		16'h0030: begin
			 if (~use_uppercase) ascii_character <= 16'h0062; // b
			 else ascii_character <= 16'h0042; // B
		end
		16'h0031: begin
			 if (~use_uppercase) ascii_character <= 16'h006e; // n
			 else ascii_character <= 16'h004e; // N
		end
		16'h0032: begin
			 if (~use_uppercase) ascii_character <= 16'h006d; // m
			 else ascii_character <= 16'h004d; // M
		end
		16'h0033: begin
			 if (~use_uppercase) ascii_character <= 16'h002c; // ,
			 else ascii_character <= 16'h003c; // <
		end
		16'h0034: begin
			 if (~use_uppercase) ascii_character <= 16'h002e; // .
			 else ascii_character <= 16'h003e; // >
		end
		16'h0035: begin
			 if (~use_uppercase) ascii_character <= 16'h002f; // /
			 else ascii_character <= 16'h003f; // ?
		end
		16'h002B: begin
			 if (~use_uppercase) ascii_character <= 16'h005c; // \
			 else ascii_character <= 16'h007c; // |
		end
		default: ascii_character <= 16'h0000;
	endcase
end

endmodule