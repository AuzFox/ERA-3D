enum {
	// primitive geometry modes
	QUADS = 2,

	// color constants
	RED   = 0xFF0000FF,
	GREEN = 0x00FF00FF,
	BLUE  = 0x0000FFFF,
	WHITE = 0xFFFFFFFF,

	// texture offsets
	GRASS = 0,
	BRICK = 64,
	WOOD  = 128,
	TILE = 192,
};

// texture fx:
// front: normal with vertex colors
// left: scale 0x-1.5x
// right: scroll
// back: transparent

int frames;
float left_offset;
float left_scale;
float right_scroll;
float rotation_angle;
float cam_radius;
vec3 cam_pos;

void init() {
	left_offset = 0.0;
	right_scroll = 0.0;
	frames = 0;
	rotation_angle = 90.0;
	cam_radius = 2.5;
	cam_pos = vec3zero();

	cullmode(2);
}

void update(float deltatime) {
	left_offset = fwrap(left_offset + 0.05, 0.0, 100.0);
	left_scale = sin(left_offset);
	right_scroll = fwrap(right_scroll + 0.0125, 0.0, 1.0);

	float delta_angle = 0.0;

	if (btn(2)) {
		delta_angle = 45.0;
	}
	if (btn(3)) {
		delta_angle = -45.0;
	}

	rotation_angle = fwrap(rotation_angle + delta_angle * deltatime, 0.0, 360.0);

	float asrad = rad(rotation_angle);
	cam_pos.x = cos(asrad) * cam_radius;
	cam_pos.z = sin(asrad) * cam_radius;

	campos(cam_pos);
}

void draw3d() {
	pushmatrix();
		// front
		texture(BRICK, 0, 64, 64);
		meshbegin(QUADS);
			color(RED);
			texcoord((vec2){0.0, 0.0});
			vertex((vec3){-0.5, 0.5, 0.5});

			color(GREEN);
			texcoord((vec2){0.0, 1.0});
			vertex((vec3){-0.5, -0.5, 0.5});

			color(BLUE);
			texcoord((vec2){1.0, 1.0});
			vertex((vec3){0.5, -0.5, 0.5});

			color(WHITE);
			texcoord((vec2){1.0, 0.0});
			vertex((vec3){0.5, 0.5, 0.5});
		meshend();

		// left
		vec2 midpoint = (vec2){0.5, 0.5};
		texture(WOOD, 0, 64, 64);
		meshbegin(QUADS);
			color(WHITE);
			texcoord(midpoint - (vec2){left_scale, left_scale});
			vertex((vec3){-0.5, 0.5, -0.5});

			texcoord(midpoint + (vec2){-left_scale, left_scale});
			vertex((vec3){-0.5, -0.5, -0.5});

			texcoord(midpoint + (vec2){left_scale, left_scale});
			vertex((vec3){-0.5, -0.5, 0.5});

			texcoord(midpoint + (vec2){left_scale, -left_scale});
			vertex((vec3){-0.5, 0.5, 0.5});
		meshend();

		// right
		vec2 scrollv = (vec2){right_scroll, right_scroll};
		texture(TILE, 0, 64, 64);
		meshbegin(QUADS);
			color(WHITE);
			texcoord((vec2){0.0, 0.0} + scrollv);
			vertex((vec3){0.5, 0.5, 0.5});

			color(BLUE);
			texcoord((vec2){0.0, 1.0} + scrollv);
			vertex((vec3){0.5, -0.5, 0.5});

			color(BLUE);
			texcoord((vec2){1.0, 1.0} + scrollv);
			vertex((vec3){0.5, -0.5, -0.5});

			color(WHITE);
			texcoord((vec2){1.0, 0.0} + scrollv);
			vertex((vec3){0.5, 0.5, -0.5});
		meshend();

		// back
		texture(0, 0, 64, 64);
		meshbegin(QUADS);
			color(WHITE);
			texcoord((vec2){0.0, 0.0});
			vertex((vec3){0.5, 0.5, -0.5});

			texcoord((vec2){0.0, 1.0});
			vertex((vec3){0.5, -0.5, -0.5});

			texcoord((vec2){1.0, 1.0});
			vertex((vec3){-0.5, -0.5, -0.5});

			texcoord((vec2){1.0, 0.0});
			vertex((vec3){-0.5, 0.5, -0.5});
		meshend();
	popmatrix();

	frames = frames + 1;
}
