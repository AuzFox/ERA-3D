// TODO: overhaul into simple paint program

enum {
	// primitive geometry modes
	QUADS = 2,

	// color constants
	RED   = 0xFF0000FF,
	GREEN = 0x00FF00FF,
	BLUE  = 0x0000FFFF,
	WHITE = 0xFFFFFFFF,
	
	TEXMEM_ADDR = 0x00800000
};

int* texmem;

void setTEXMEMPixel(int x, int y, int col) {
	x = midi(0, x, 1023);
	y = midi(0, y, 1023);
	texmem[y * 1024 + x] = col;
}

void init() {
	texmem = (int*)TEXMEM_ADDR; // get pointer to the start of TEXMEM
}

void update(float delta_time) {
	if (pressed(0, 5)) {
		setTEXMEMPixel(0, 0, RED);
		setTEXMEMPixel(0, 2, GREEN);
		setTEXMEMPixel(0, 4, BLUE);
	}
}

void draw() {
	clear(0x000000FF);
	camera2D(0);
	sprite2D(0, 0, 8, 8, 8, 8);
}
