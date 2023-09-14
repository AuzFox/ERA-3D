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

	// color constants
	BLACK          = 0x000000FF,
	RED            = 0xFF0000FF,
	WHITE_NO_ALPHA = 0xFFFFFF00, // used as a base for non-tinted transparency
	WHITE          = 0xFFFFFFFF,

	TMEM_START = 0x008C0000, // TMEM start address
	TMEM_W = 1024,         // each row in TMEM is 1024 pixels wide (1 pixel = 32-bit RGBA)
	GRID_W = 64,
	GRID_H = 64,
	OFFSETS_SIZE = 8
};

int* current_grid;
int* next_grid;
vec2 offsets[OFFSETS_SIZE];

int running;
int frames;
int wait_frames;

int cursor_x;
int cursor_y;
float cursor_anim;

int getCell(int* grid, int x, int y) {
	x = wrapi(x, 0, GRID_W - 1);
	y = wrapi(y, 0, GRID_H - 1);
	
	return grid[TMEM_W * y + x];
}

void setCell(int* grid, int x, int y, int val) {
	x = wrapi(x, 0, GRID_W - 1);
	y = wrapi(y, 0, GRID_H - 1);
	
	grid[TMEM_W * y + x] = val;
}

void clearGrids() {
	for (int y = 0; y < GRID_H; y = y + 1) {
		for (int x = 0; x < GRID_W; x = x + 1) {
			setCell(current_grid, x, y, WHITE);
			setCell(next_grid, x, y, WHITE);
		}
	}
}

int getNeighbours(int* grid, int x, int y) {
	vec2 offset;
	int total = 0;

	for (int i = 0; i < 8; i = i + 1) {
		offset = offsets[i];
		total = total + (getCell(grid, x + (int)offset.x, y + (int)offset.y) == BLACK);
	}

	return total;
}

void init() {
	// start first grid at (0, 0) in TMEM
	current_grid = (int*)TMEM_START;

	// start second grid at (0, GRID_H) in TMEM
	next_grid = (int*)TMEM_START + (GRID_H * TMEM_W);

	// fill offsets table
	offsets[0] = (vec2){-1, -1};
	offsets[1] = (vec2){ 0, -1};
	offsets[2] = (vec2){ 1, -1};
	offsets[3] = (vec2){-1,  0};
	offsets[4] = (vec2){ 1,  0};
	offsets[5] = (vec2){-1,  1};
	offsets[6] = (vec2){ 0,  1};
	offsets[7] = (vec2){ 1,  1};

	clearGrids();
	
	running = 0;
	frames = 0;
	wait_frames = 2;

	cursor_x = GRID_W / 2;
	cursor_y = GRID_H / 2;

	cursor_anim = 0.0;
}

void update(float delta_time) {
	cursor_anim = cursor_anim + 0.2;
	
	if (pressed(BTN_L1, 0)) {
		wait_frames = midi(1, wait_frames - 1, 30);
		frames = 0;
	}
	else if (pressed(BTN_R1, 0)) {
		wait_frames = midi(1, wait_frames + 1, 30);
		frames = 0;
	}
	
	if (pressed(BTN_START, 0)) {
		running = !running;
		frames = 0;
	}

	if (!running) {
		int dx = 0;
		int dy = 0;
		
		if (pressed(BTN_UP, 0)) {
			dy = dy - 1;
		}
		if (pressed(BTN_DOWN, 0)) {
			dy = dy + 1;
		}
		if (pressed(BTN_LEFT, 0)) {
			dx = dx - 1;
		}
		if (pressed(BTN_RIGHT, 0)) {
			dx = dx + 1;
		}

		cursor_x = wrapi(cursor_x + dx, 0, GRID_W - 1);
		cursor_y = wrapi(cursor_y + dy, 0, GRID_H - 1);

		if (pressed(BTN_SELECT, 0)) {
			clearGrids();
		}
		else if (pressed(BTN_CROSS, 0)) {
			setCell(current_grid, cursor_x, cursor_y, BLACK);
		}
		else if (pressed(BTN_CIRCLE, 0)) {
			setCell(current_grid, cursor_x, cursor_y, WHITE);
		}
		else if (pressed(BTN_SQUARE, 0)) {
			int cell = getCell(current_grid, cursor_x, cursor_y);

			if (cell == BLACK) {
				cell = WHITE;
			}
			else {
				cell = BLACK;
			}
			
			setCell(current_grid, cursor_x, cursor_y, cell);
		}
	}
	else {
		frames = frames + 1;
		if (frames >= wait_frames) {
			frames = 0;
		}
		else {
			return;
		}

		// advance simulation
		int cell;
		int neighbours;
	
		for (int y = 0; y < GRID_H; y = y + 1) {
			for (int x = 0; x < GRID_W; x = x + 1) {
				cell = getCell(current_grid, x, y);
				neighbours = getNeighbours(current_grid, x, y);
	
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
	
				setCell(next_grid, x, y, cell);
			}
		}
	
		// swap grids
		int* temp = current_grid;
		current_grid = next_grid;
		next_grid = temp;
	}
}

void draw() {
	clear(0x000000FF);
	camera2D(0);

	// get y texturesheet coordinate of the current grid
	int srcy = 0;
	if (current_grid != TMEM_START) {
		srcy = GRID_H;
	}
	
	// draw the current grid
	//
	// the grid is drawn in the center of the screen at 2x scale
	int gridx = (320 / 2) - GRID_W; // x screen coordinate of the grid
	int gridy = (240 / 2) - GRID_H; // y screen coordinate of the grid
	sprite2DEx(0, srcy, GRID_W, GRID_H, gridx, gridy, GRID_W * 2, GRID_H * 2);
	
	// draw the cursor
	//
	// we use the advanced graphics functions to draw the cursor,
	// this allows us to create a blinking effect using vertex alpha values
	// 
	// 2d vertices are positioned using screen pixel coordinates
	
	if (!running) {
		vec2 cursorpos = (vec2){
			(float)(gridx + cursor_x * 2),
			(float)(gridy + cursor_y * 2),
		};
		
		texture(1023, 0, 1, 1);
		beginMesh(QUADS);
			// ping-pong between 25% and 100% transparency, no tinting
			vertColor(WHITE_NO_ALPHA | (int)(((1.0 + sin(cursor_anim)) * 0.375 + 0.25) * 255.0));
			
			vertUV((vec2){0.0, 0.0});
			vertex2D(cursorpos);

			vertUV((vec2){0.0, 1.0});
			vertex2D(cursorpos + (vec2){0.0, 2.0});

			vertUV((vec2){1.0, 1.0});
			vertex2D(cursorpos + (vec2){2.0, 2.0});

			vertUV((vec2){1.0, 0.0});
			vertex2D(cursorpos + (vec2){2.0, 0.0});
		endMesh();
	}
}
