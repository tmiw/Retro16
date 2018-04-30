module keyboard_handler(
	global_clk, 
	ps2_clk, 
	ps2_data,
	keyboard_ram_addr,
	keyboard_ram_data,
	keyboard_interrupt);
	
input global_clk;
inout ps2_clk;
inout ps2_data;
input [15:0] keyboard_ram_addr;
output reg [15:0] keyboard_ram_data;
output keyboard_interrupt;

wire [7:0] decoded_key;
wire read_key;
ps2_keyboard keyboard(global_clk, ps2_clk, ps2_data, decoded_key, read_key);

wire [15:0] set2_key_out;
wire key_break_out;
key_break_decoder set_2_decoder(
	global_clk, 
	decoded_key, 
	read_key, 
	set2_key_out, 
	key_break_out, 
	keyboard_interrupt);

wire [15:0] set1_key_out;
set2_to_set1_translator set1_translator(
	set2_key_out,
	key_break_out,
	set1_key_out);

wire [15:0] ascii_char_out;
set1_to_ascii_translator ascii_translator(
	set1_key_out,
	key_break_out,
	ascii_char_out);
	
always @(posedge global_clk)
begin
	case (keyboard_ram_addr)
	16'h0000: keyboard_ram_data <= set1_key_out;
	16'h0001: keyboard_ram_data <= ascii_char_out;
	default: keyboard_ram_data <= 16'h0000;
	endcase
end

endmodule