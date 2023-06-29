enum {
	// primitive geometry modes
	LINES,
	TRIANGLES,
	QUADS,

	// virtual controller buttons
	BTN_UP = 0,
	BTN_DOWN,
	BTN_LEFT,
	BTN_RIGHT,
	BTN_TRIANGLE,
	BTN_CROSS,
	BTN_SQUARE,
	BTN_CIRCLE,
	BTN_L1,
	BTN_L2,
	BTN_R1,
	BTN_R2,
	BTN_SELECT,
	BTN_START,

	TMEM_START = 0x800000, // TMEM start address
	TMEM_W = 1024,         // each row in TMEM is 1024 pixels wide (1 pixel = 32-bit RGBA)
	GRID_W = 64,
	GRID_H = 64,

	// color constants
	BLACK          = 0x000000FF,
	RED            = 0xFF0000FF,
	WHITE_NO_ALPHA = 0xFFFFFF00, // used as a base for non-tinted transparency
	WHITE          = 0xFFFFFFFF
};

int* curgrid;
int* nextgrid;
vec2* offsets;

int running;
int frames;
int waitframes;

int cursorx;
int cursory;
float cursoranim;

int getcell(int* grid, int x, int y) {
	x = iwrap(x, 0, GRID_W - 1);
	y = iwrap(y, 0, GRID_H - 1);
	
	return *(grid + (TMEM_W * y + x));
}

void setcell(int* grid, int x, int y, int val) {
	x = iwrap(x, 0, GRID_W - 1);
	y = iwrap(y, 0, GRID_H - 1);
	
	*(grid + (TMEM_W * y + x)) = val;
}

void cleargrids() {
	int x;
	int y = 0;

	while (y < GRID_H) {
		x = 0;
		while (x < GRID_W) {
			setcell(curgrid, x, y, WHITE);
			setcell(nextgrid, x, y, WHITE);

			x = x + 1;
		}
		y = y + 1;
	}
}

int getneighbours(int* grid, int x, int y) {
	vec2 offset;
	int total = 0;
	int i = 0;

	while (i < 8) {
		offset = *(offsets + i);
		total = total + (getcell(grid, x + (int)offset.x, y + (int)offset.y) == BLACK);

		i = i + 1;
	}

	return total;
}

void init() {
	// start first grid at (0, 0) in TMEM
	curgrid = (int*)TMEM_START;

	// start second grid at (0, GRID_H) in TMEM
	nextgrid = (int*)TMEM_START + (GRID_H * TMEM_W);

	// store offsets table in the heap
	offsets = (int*)0x000000;

	// fill offsets table
	*(offsets    ) = (vec2){-1, -1};
	*(offsets + 1) = (vec2){ 0, -1};
	*(offsets + 2) = (vec2){ 1, -1};
	*(offsets + 3) = (vec2){-1,  0};
	*(offsets + 4) = (vec2){ 1,  0};
	*(offsets + 5) = (vec2){-1,  1};
	*(offsets + 6) = (vec2){ 0,  1};
	*(offsets + 7) = (vec2){ 1,  1};

	cleargrids();
	
	running = 0;
	frames = 0;
	waitframes = 2;

	cursorx = GRID_W / 2;
	cursory = GRID_H / 2;

	cursoranim = 0.0;
}

void update(float deltatime) {
	cursoranim = cursoranim + 0.2;
	
	if (btnd(BTN_L1)) {
		waitframes = imid(1, waitframes - 1, 30);
		frames = 0;
	}
	else if (btnd(BTN_R1)) {
		waitframes = imid(1, waitframes + 1, 30);
		frames = 0;
	}
	
	if (btnd(BTN_START)) {
		running = !running;
		frames = 0;
	}

	if (!running) {
		int dx = 0;
		int dy = 0;
		
		if (btnd(BTN_UP)) {
			dy = dy - 1;
		}
		if (btnd(BTN_DOWN)) {
			dy = dy + 1;
		}
		if (btnd(BTN_LEFT)) {
			dx = dx - 1;
		}
		if (btnd(BTN_RIGHT)) {
			dx = dx + 1;
		}

		cursorx = iwrap(cursorx + dx, 0, GRID_W - 1);
		cursory = iwrap(cursory + dy, 0, GRID_H - 1);

		if (btnd(BTN_SELECT)) {
			cleargrids();
		}
		else if (btnd(BTN_CROSS)) {
			setcell(curgrid, cursorx, cursory, BLACK);
		}
		else if (btnd(BTN_CIRCLE)) {
			setcell(curgrid, cursorx, cursory, WHITE);
		}
		else if (btnd(BTN_SQUARE)) {
			int cell = getcell(curgrid, cursorx, cursory);

			if (cell == BLACK) {
				cell = WHITE;
			}
			else {
				cell = BLACK;
			}
			
			setcell(curgrid, cursorx, cursory, cell);
		}
	}
	else {
		frames = frames + 1;
		if (frames >= waitframes) {
			frames = 0;
		}
		else {
			return;
		}

		// advance simulation
		int x;
		int y = 0;
		int cell;
		int neighbours;
	
		while (y < GRID_H) {
			x = 0;
			while (x < GRID_W) {
				cell = getcell(curgrid, x, y);
				neighbours = getneighbours(curgrid, x, y);
	
				if (cell == BLACK) {
					if (neighbours < 2 || neighbours > 3) {
						cell = WHITE;
					}
				}
				else {
					if (neighbours == 3) {
						cell = BLACK;
					}
				}
	
				setcell(nextgrid, x, y, cell);
				
				x = x + 1;
			}
			y = y + 1;
		}
	
		// swap grids
		int* temp = curgrid;
		curgrid = nextgrid;
		nextgrid = temp;
	}
}

void draw2d() {
	// get y texturesheet coordinate of the current grid
	int srcy = 0;
	if (curgrid != TMEM_START) {
		srcy = GRID_H;
	}
	
	// draw the current grid
	//
	// the grid is drawn in the centered of the screen at 2x scale
	int gridx = (320 / 2) - GRID_W; // x screen coordinate of the grid
	int gridy = (240 / 2) - GRID_H; // y screen coordinate of the grid
	ssprite2d(0, srcy, GRID_W, GRID_H, gridx, gridy, GRID_W * 2, GRID_H * 2);
	
	// draw the cursor
	//
	// we use the advanced graphics functions to draw the cursor,
	// this allows us to create a blinking effect using vertex alpha values
	// 
	// 2d vertices are positioned using screen pixel coordinates
	
	if (!running) {
		vec2 cursorpos = (vec2){
			(float)(gridx + cursorx * 2),
			(float)(gridy + cursory * 2),
		};
		
		texture(1023, 0, 1, 1);
		meshbegin(QUADS);
			// ping-pong between 25% and 100% transparency, no tinting
			color(WHITE_NO_ALPHA | (int)(((1.0 + sin(cursoranim)) * 0.375 + 0.25) * 255.0));
			
			texcoord((vec2){0.0, 0.0});
			vertex2d(cursorpos);

			texcoord((vec2){0.0, 1.0});
			vertex2d(cursorpos + (vec2){0.0, 2.0});

			texcoord((vec2){1.0, 1.0});
			vertex2d(cursorpos + (vec2){2.0, 2.0});

			texcoord((vec2){1.0, 0.0});
			vertex2d(cursorpos + (vec2){2.0, 0.0});
		meshend();
	}
}
