# const: 0xf82f
# const: 0x0748 (H)
# const: 0x0765 (e)
# const: 0x076c (l)
# const: 0x076c (l)
# const: 0x076f (o)

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
