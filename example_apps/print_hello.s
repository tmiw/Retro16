			16'h0000: data_out <= 16'hf82f; // const: 0xf82f
			16'h0001: data_out <= 16'h0748; // const: 0x0748 (H)
			16'h0002: data_out <= 16'h0765; // const: 0x0765 (e)
			16'h0003: data_out <= 16'h076c; // const: 0x076c (l)
			16'h0004: data_out <= 16'h076c; // const: 0x076c (l)
			16'h0005: data_out <= 16'h076f; // const: 0x076f (o)
			16'h0100: data_out <= 16'h4400; // ld r1, r0, 0
			16'h0101: data_out <= 16'h4801; // ld r2, r0, 1
			16'h0102: data_out <= 16'h6500; // st r1, r2, 0
			16'h0103: data_out <= 16'h4802; // ld r2, r0, 2
			16'h0104: data_out <= 16'h6501; // st r1, r2, 1
			16'h0105: data_out <= 16'h4803; // ld r2, r0, 3
			16'h0106: data_out <= 16'h6502; // st r1, r2, 2
			16'h0107: data_out <= 16'h4804; // ld r2, r0, 4
			16'h0108: data_out <= 16'h6503; // st r1, r2, 3
			16'h0109: data_out <= 16'h4805; // ld r2, r0, 5
			16'h010a: data_out <= 16'h6504; // st r1, r2, 4
			16'h010b: data_out <= 16'h8ff6; // br 0x0102
