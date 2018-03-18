.raw 0xC000				# Keyboard scan code register
.raw 0xF82F				# Video memory offset
.raw 0x0700				# BG/FG color

start:
	ld r1, r0, 0
	ld r2, r0, 1
	ld r3, r1, 0
	shr r4, r3, 4
	and r4, r4, 15
	add r5, r4, -9
	bgt hex_out1
	ld r5, r0, 2 		# ASCII 0
	br out_1
hex_out1:
	ld r5, r0, 3		# ASCII A
out_1:
	add r4, r4, r5
	ld r5, r0, 3 
	or r4, r4, r5
	st r2, r4, 0
	and r4, r3, 15
	add r5, r4, -9
	bgt hex_out2
	ld r5, r0, 2
	br out_2
hex_out2:
	ld r5, r0, 3
out_2:
	add r4, r4, r5
	ld r5, r0, 3
	or r4, r4, r5
	st r2, r4, 0
	br start
