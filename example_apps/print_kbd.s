.raw 0xC000				# Keyboard scan code register
.raw 0xF82F				# Video memory offset
.raw 0x0730				# ASCII 0
.raw 0x0741				# ASCII A

start:
	ld r1, r0, 0			# Load scan code address into r1
	ld r2, r0, 1			# Load video memory address into r2
loop:
	ld r3, r1, 0			# Load keyboard scan code into r3
	and r4, r3, 15			# r4 = r3 && 0xF (isolate last four bits)
	add r4, r4, -10			# r4 = r4 - 10 
	bgt hex_out1			# if (r4 > 0) jump to hex_out1
	add r4, r4, 10			# r4 = r4 + 10
	ld r5, r0, 2			# Load ASCII 0 into r5
	br out_1			# Jump to out_1
hex_out1:
	ld r5, r0, 3			# Load ASCII A into r5
out_1:
	add r4, r4, r5			# r4 = r4 + r5
	st r2, r4, 1			# Store r4 at video memory + 1
	shr r4, r3, 4			# Shift r3 right by 4 bits
	and r4, r4, 15			# r4 = r4 && 0xF (isolate last four bits)
	add r4, r4, -10			# r4 = r4 - 10
	bgt hex_out2			# if (r4 > 0) jump to hex_out2 jump to hex_out2
	add r4, r4, 10			# r4 = r4 + 10
	ld r5, r0, 2			# Load ASCII 0 into r5
	br out_2			# Jump to out_2
hex_out2:
	ld r5, r0, 3			# Load ASCII A into r5
out_2:
	add r4, r4, r5			# r4 = r4 + r5
	st r2, r4, 0			# Store r4 at video memory + 0
	br loop				# Jump to loop
