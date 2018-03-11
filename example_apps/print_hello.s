.raw 0xf82f # Address of display buffer
.raw 0x0748 # ASCII H, black on white
.raw 0x0765 # ASCII e
.raw 0x076c # ASCII l
.raw 0x076c # ASCII l
.raw 0x076f # ASCII o

start:
	ld r1, r0, 0
	ld r2, r0, 1
	st r1, r2, 0
	ld r2, r0, 2
	st r1, r2, 1
	ld r2, r0, 3
	st r1, r2, 2
	ld r2, r0, 4
	st r1, r2, 3
	ld r2, r0, 5
	st r1, r2, 4
	br start
