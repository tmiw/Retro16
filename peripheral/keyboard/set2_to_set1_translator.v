module set2_to_set1_translator(
	set2_key_in,
	set2_key_break_in,
	set1_key_out);
	
input [15:0] set2_key_in;
input set2_key_break_in;
output [15:0] set1_key_out;

reg [16:0] set1_lsb;

always @(*)
begin
	case (set2_key_in)
	16'h000E: set1_lsb <= 16'h0029;
	16'h0016: set1_lsb <= 16'h0002;
	16'h001E: set1_lsb <= 16'h0003;
	16'h0026: set1_lsb <= 16'h0004;
	16'h0025: set1_lsb <= 16'h0005;
	16'h002E: set1_lsb <= 16'h0006;
	16'h0036: set1_lsb <= 16'h0007;
	16'h003D: set1_lsb <= 16'h0008;
	16'h003E: set1_lsb <= 16'h0009;
	16'h0046: set1_lsb <= 16'h000A;
	16'h0045: set1_lsb <= 16'h000B;
	16'h004E: set1_lsb <= 16'h000C;
	16'h0055: set1_lsb <= 16'h000D;
	16'h0066: set1_lsb <= 16'h000E;
	16'h000D: set1_lsb <= 16'h000F;
	16'h0015: set1_lsb <= 16'h0010;
	16'h001D: set1_lsb <= 16'h0011;
	16'h0024: set1_lsb <= 16'h0012;
	16'h002D: set1_lsb <= 16'h0013;
	16'h002C: set1_lsb <= 16'h0014;
	16'h0035: set1_lsb <= 16'h0015;
	16'h003C: set1_lsb <= 16'h0016;
	16'h0043: set1_lsb <= 16'h0017;
	16'h0044: set1_lsb <= 16'h0018;
	16'h004D: set1_lsb <= 16'h0019;
	16'h0054: set1_lsb <= 16'h001A;
	16'h005B: set1_lsb <= 16'h001B;
	16'h0058: set1_lsb <= 16'h003A;
	16'h001C: set1_lsb <= 16'h001E;
	16'h001B: set1_lsb <= 16'h001F;
	16'h0023: set1_lsb <= 16'h0020;
	16'h002B: set1_lsb <= 16'h0021;
	16'h0034: set1_lsb <= 16'h0022;
	16'h0033: set1_lsb <= 16'h0023;
	16'h003B: set1_lsb <= 16'h0024;
	16'h0042: set1_lsb <= 16'h0025;
	16'h004B: set1_lsb <= 16'h0026;
	16'h004C: set1_lsb <= 16'h0027;
	16'h0052: set1_lsb <= 16'h0028;
	16'h005A: set1_lsb <= 16'h001C;
	16'h0012: set1_lsb <= 16'h002A;
	16'h001A: set1_lsb <= 16'h002C;
	16'h0022: set1_lsb <= 16'h002D;
	16'h0021: set1_lsb <= 16'h002E;
	16'h002A: set1_lsb <= 16'h002F;
	16'h0032: set1_lsb <= 16'h0030;
	16'h0031: set1_lsb <= 16'h0031;
	16'h003A: set1_lsb <= 16'h0032;
	16'h0041: set1_lsb <= 16'h0033;
	16'h0049: set1_lsb <= 16'h0034;
	16'h004A: set1_lsb <= 16'h0035;
	16'h0059: set1_lsb <= 16'h0036;
	16'h0014: set1_lsb <= 16'h001D;
	16'h0011: set1_lsb <= 16'h0038;
	16'h0029: set1_lsb <= 16'h0039;
	16'hE011: set1_lsb <= 16'hE038;
	16'hE014: set1_lsb <= 16'hE01D;
	16'hE070: set1_lsb <= 16'hE052;
	16'hE071: set1_lsb <= 16'hE04B;
	16'hE06B: set1_lsb <= 16'hE04B;
	16'hE06C: set1_lsb <= 16'hE047;
	16'hE069: set1_lsb <= 16'hE04F;
	16'hE075: set1_lsb <= 16'hE048;
	16'hE072: set1_lsb <= 16'hE050;
	16'hE07D: set1_lsb <= 16'hE049;
	16'hE07A: set1_lsb <= 16'hE051;
	16'hE074: set1_lsb <= 16'hE04D;
	16'h0077: set1_lsb <= 16'h0045;
	16'h006C: set1_lsb <= 16'h0047;
	16'h006B: set1_lsb <= 16'h004B;
	16'h0069: set1_lsb <= 16'h004F;
	16'hE04A: set1_lsb <= 16'hE035;
	16'h0075: set1_lsb <= 16'h0048;
	16'h0073: set1_lsb <= 16'h004C;
	16'h0072: set1_lsb <= 16'h0050;
	16'h0070: set1_lsb <= 16'h0052;
	16'h007C: set1_lsb <= 16'h0037;
	16'h007D: set1_lsb <= 16'h0049;
	16'h0074: set1_lsb <= 16'h004D;
	16'h007A: set1_lsb <= 16'h0051;
	16'h0071: set1_lsb <= 16'h0053;
	16'h007B: set1_lsb <= 16'h004A;
	16'h0079: set1_lsb <= 16'h004E;
	16'hE05A: set1_lsb <= 16'hE01C;
	16'h0076: set1_lsb <= 16'h0001;
	16'h0005: set1_lsb <= 16'h003B;
	16'h0006: set1_lsb <= 16'h003C;
	16'h0004: set1_lsb <= 16'h003D;
	16'h000C: set1_lsb <= 16'h003E;
	16'h0003: set1_lsb <= 16'h003F;
	16'h000B: set1_lsb <= 16'h0040;
	16'h0083: set1_lsb <= 16'h0041;
	16'h000A: set1_lsb <= 16'h0042;
	16'h0001: set1_lsb <= 16'h0043;
	16'h0009: set1_lsb <= 16'h0044;
	16'h0078: set1_lsb <= 16'h0057;
	16'h0007: set1_lsb <= 16'h0058;
	16'h007E: set1_lsb <= 16'h0046;
	16'h005D: set1_lsb <= 16'h002B;
	default: begin
		// Print Screen/Pause/Break not supported.
		set1_lsb <= 16'h0000;
	end
	endcase
end

assign set1_key_out = {set1_lsb[15:8], set2_key_break_in, set1_lsb[6:0]};

endmodule