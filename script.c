/*
enum {
	// primitive geometry modes
	LINES,
	TRIANGLES,
	QUADS,

	// color constants
	WHITE = 0xFFFFFFFF
};

float light_move_radius;
float light_shine_radius;
float light_angle;
vec3 light_pos;

float direction;
vec3 rotation;

int dist_to_color(float dist) {
	float percentage = (1.0 - fclamp(dist / light_shine_radius, 0.0, 1.0)) * 255.0;

	int byte = percentage;
	
	return (byte << 24) | (byte << 16) | (byte << 8) | 0xFF;
}

void init() {
	light_move_radius = 1.5;
	light_shine_radius = 2.0;
	light_angle = 0.0;
	light_pos = v3(0.0, 0.0, 0.1);
	rotation = v3zero();
	direction = 1.0;
}

void update() {
	light_angle = (light_angle + 2.0) % 360.0;

	float asrad = rad(light_angle);
	light_pos.x = cos(asrad) * light_move_radius;
	light_pos.y = sin(asrad) * light_move_radius;

	rotation.y = rotation.y + direction;

	if (rotation.y < -45.0 || rotation.y > 45.0) {
		direction = -direction;
	}
}

void draw3d() {
	pushmatrix();
		translate(light_pos);
		
		meshbegin(QUADS);
			color(WHITE);
			texcoord(v2(0.1, 0.98));
			vertex(v3(0.0, 0.05, 0.0));

			texcoord(v2(0.0, 0.99));
			vertex(v3(-0.05, 0.0, 0.0));

			texcoord(v2(0.1, 1.0));
			vertex(v3(0.0, -0.05, 0.0));
			
			texcoord(v2(0.2, 0.99));
			vertex(v3(0.05, 0.0, 0.0));
		meshend();
	popmatrix();
	
	pushmatrix();
		rotate(rotation);
		
		// draw vertex-colored textured quad
		// 
		// counter-clockwise winding order
		meshbegin(QUADS);
			// top-left
			color(dist_to_color(v3dist(light_pos, v3(-1.0, 1.0, 0.0))));
			texcoord(v2(0.0, 0.0));
			vertex(v3(-1.0, 1.0, 0.0));

			// bottom-left
			color(dist_to_color(v3dist(light_pos, v3(-1.0, -1.0, 0.0))));
			texcoord(v2(0.0, 1.0));
			vertex(v3(-1.0, -1.0, 0.0));

			// bottom-right
			color(dist_to_color(v3dist(light_pos, v3(1.0, -1.0, 0.0))));
			texcoord(v2(1.0, 1.0));
			vertex(v3(1.0, -1.0, 0.0));

			// top-right
			color(dist_to_color(v3dist(light_pos, v3(1.0, 1.0, 0.0))));
			texcoord(v2(1.0, 0.0));
			vertex(v3(1.0, 1.0, 0.0));
		meshend();
	popmatrix();
}
*/

enum {
	// primitive geometry modes
	LINES,
	TRIANGLES,
	QUADS,

	BTN_UP = 0,
	BTN_DOWN,
	BTN_LEFT,
	BTN_RIGHT,
	BTN_A,
	BTN_S,
	BTN_Q,
	BTN_W,
	BTN_Z,

	GRID_W = 64,
	GRID_H = 64,

	// color constants
	RED   = 0xFF0000FF,
	BLACK = 0x000000FF,
	WHITE = 0xFFFFFFFF
};

int GRID_SIZE;

int* cur_grid;
int* next_grid;

vec2* offsets_table;

int sx;
int sy;
int running;
int frames;
int waitframes;

int get_cell(int* grid, int x, int y) {
	x = iwrap(x, 0, GRID_W - 1);
	y = iwrap(y, 0, GRID_H - 1);
	
	return *(grid + (GRID_W * y + x));
}

void set_cell(int* grid, int x, int y, int val) {
	x = iwrap(x, 0, GRID_W - 1);
	y = iwrap(y, 0, GRID_H - 1);
	
	*(grid + (GRID_W * y + x)) = val;
}

void clear_grids() {
	int x;
	int y = 0;

	while (y < GRID_H) {
		x = 0;
		while (x < GRID_W) {
			set_cell(cur_grid, x, y, 0);
			set_cell(next_grid, x, y, 0);

			x = x + 1;
		}
		y = y + 1;
	}
}

int get_neighbours(int* grid, int x, int y) {
	vec2 offset;
	int total = 0;
	int i = 0;

	while (i < 8) {
		offset = *(offsets_table + i);
		total = total + get_cell(grid, x + (int)offset.x, y + (int)offset.y);

		i = i + 1;
	}

	return total;
}

void draw_cell(int x, int y, int cell) {
	int col;
	vec3 pos = v3zero();

	if (cell) {
		col = BLACK;
	}
	else {
		col = WHITE;
	}

	pos.x = (-(0.5 * (float)GRID_W) + (float)x) + 0.5;
	pos.y = (-(0.5 * (float)GRID_W) + (float)y) + 0.5;

	if (!running && x == sx && y == sy) {
		col = RED;
	}

	color(col);
	texcoord(v2(0.1, 0.98));
	vertex(pos + v3(-0.5, 0.5, 0.0));
	texcoord(v2(0.0, 0.99));
	vertex(pos + v3(-0.5, -0.5, 0.0));
	texcoord(v2(0.1, 1.0));
	vertex(pos + v3(0.5, -0.5, 0.0));
	texcoord(v2(0.2, 0.99));
	vertex(pos + v3(0.5, 0.5, 0.0));
}

void init() {
	GRID_SIZE = (GRID_W * GRID_H * 4);
	running = 0;
	frames = 0;

	sx = GRID_W / 2;
	sy = GRID_H / 2;

	waitframes = 2;
	
	cur_grid = 0;
	next_grid = GRID_SIZE;
	offsets_table = GRID_SIZE * 2;

	// fill offsets table
	*(offsets_table    ) = v2(-1, -1);
	*(offsets_table + 1) = v2( 0, -1);
	*(offsets_table + 2) = v2( 1, -1);
	*(offsets_table + 3) = v2(-1,  0);
	*(offsets_table + 4) = v2( 1,  0);
	*(offsets_table + 5) = v2(-1,  1);
	*(offsets_table + 6) = v2( 0,  1);
	*(offsets_table + 7) = v2( 1,  1);

	clear_grids();
}

void update() {
	if (btnd(BTN_Q)) {
		waitframes = imid(1, waitframes - 1, 30);
		frames = 0;
	}
	else if (btnd(BTN_W)) {
		waitframes = imid(1, waitframes + 1, 30);
		frames = 0;
	}
	
	if (btnd(BTN_S)) {
		running = !running;
		frames = 0;
	}

	if (!running) {
		int dx = 0;
		int dy = 0;
		
		if (btnd(BTN_UP)) {
			dy = dy + 1;
		}
		if (btnd(BTN_DOWN)) {
			dy = dy - 1;
		}
		if (btnd(BTN_LEFT)) {
			dx = dx - 1;
		}
		if (btnd(BTN_RIGHT)) {
			dx = dx + 1;
		}

		sx = iwrap(sx + dx, 0, GRID_W - 1);
		sy = iwrap(sy + dy, 0, GRID_H - 1);

		if (btnd(BTN_Z)) {
			clear_grids();
		}
		else if (btnd(BTN_A)) {
			set_cell(cur_grid, sx, sy, !get_cell(cur_grid, sx, sy));
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
				cell = get_cell(cur_grid, x, y);
				neighbours = get_neighbours(cur_grid, x, y);
	
				if (cell) {
					if (neighbours < 2 || neighbours > 3) {
						cell = 0;
					}
				}
				else {
					if (neighbours == 3) {
						cell = 1;
					}
				}
	
				set_cell(next_grid, x, y, cell);
				
				x = x + 1;
			}
			y = y + 1;
		}
	
		// swap grids
		int* temp = cur_grid;
		cur_grid = next_grid;
		next_grid = temp;
	}
}

void draw3d() {
	int x;
	int y = 0;

	// draw current grid
	pushmatrix();
		meshbegin(QUADS);
			while (y < GRID_H) {
				x = 0;
				while (x < GRID_W) {
					draw_cell(x, y, get_cell(cur_grid, x, y));

					x = x + 1;
				}
				y = y + 1;
			}
		meshend();
	popmatrix();
}
