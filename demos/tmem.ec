enum {
	// primitive geometry modes
	QUADS = 2,

	// color constants
	RED   = 0xFF0000FF,
	GREEN = 0x00FF00FF,
	BLUE  = 0x0000FFFF,
	WHITE = 0xFFFFFFFF,
	
	TMEM_ADDR = 0x800000
};

int* tmem;

void set_tmem_pixel(int x, int y, int col) {
	x = imid(0, x, 1023);
	y = imid(0, y, 1023);
	*(tmem + (y * 1024 + x)) = col;
}

void init() {
	tmem = TMEM_ADDR; // get pointer to the start of TMEM
}

void update(float deltatime) {
	if (btnd(5)) {
		set_tmem_pixel(0, 0, RED);
		set_tmem_pixel(0, 2, GREEN);
		set_tmem_pixel(0, 4, BLUE);
	}
}

void draw2d() {
	sprite2d(0, 0, 8, 8, 8, 8);
}
