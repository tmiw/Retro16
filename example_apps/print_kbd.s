main:
	ld r1, r0, 0 ; Keyboard scan code register
	ld r2, r0, 1 ; Video memory offset
	ld r3, r1, 0 ; Load scan code into register
	shr r4, r3, 4 ; Most significant nibble
	and r4, r4, 0xF
	sub r5, r4, 9
	brg hex_out1
	ld r5, r0, 2 ; ASCII 0
	br out_1
hex_out1:
	ld r5, r0, 3 ; ASCII A
out_1:
	add r4, r4, r5
	ld r5, r0, 3 ; BG/FG color
	or r4, r4, r5 ; Add BG/FG color to character
	st r2, r4, 0 ; Write character to display
	and r4, r3, 0xF ; Least significant nibble
	sub r5, r4, 9
	brg hex_out2
	ld r5, r0, 2 ; ASCII 0
	br out_2
hex_out2:
	ld r5, r0, 3 ; ASCII A
out_2:
	add r4, r4, r5
	ld r5, r0, 3 ; BG/FG color
	or r4, r4, r5 ; Add BG/FG color to character
	st r2, r4, 0 ; Write character to display
	br main
	
// ===========================================================================

0100 0100 0000 0000
0100 1000 0000 0001
0100 1100 1000 0000
