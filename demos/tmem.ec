// TODO: overhaul into simple paint program

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

void setTMEMPixel(int x, int y, int col) {
	x = midi(0, x, 1023);
	y = midi(0, y, 1023);
	*(tmem + (y * 1024 + x)) = col;
}

void init() {
	tmem = TMEM_ADDR; // get pointer to the start of TMEM
}

void update(float delta_time) {
	if (buttonDown(5)) {
		setTMEMPixel(0, 0, RED);
		setTMEMPixel(0, 2, GREEN);
		setTMEMPixel(0, 4, BLUE);
	}
}

void draw2D() {
	sprite2D(0, 0, 8, 8, 8, 8);
}
