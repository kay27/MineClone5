import png
from random import randrange

w, h = 16, 256;

s = [[int(0) for c in range(w)] for c in range(h)] 

def drawpixel(x, y, t):
	if (x >= 0) and (x < w) and (y >= 0) and (y < h):
		s[y][x] = t

# R, G, B, Alpha (0xFF = opaque):
palette=[
	(0x00,0x00,0x00,0x00),
	(0xFF,0xFF,0x70,0xCC),
	(0xFF,0x80,0xDF,0xCC),
	(0x80,0xFF,0xDF,0xCC)
]

for x in range(w):
	for y in range(h):
		n = randrange(4)
		if n == 1:
			drawpixel(x, y, randrange(3) + 1)

w = png.Writer(len(s[0]), len(s), palette=palette, bitdepth=2)
f = open('mcl_end_crystal_beam.png', 'wb')
w.write(f, s)
