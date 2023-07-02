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
	cam_pos = vec3Zero();

	setCullMode(2);
}

void update(float deltatime) {
	left_offset = wrapf(left_offset + 0.05, 0.0, 100.0);
	left_scale = sin(left_offset);
	right_scroll = wrapf(right_scroll + 0.0125, 0.0, 1.0);

	float delta_angle = 0.0;

	if (buttonHeld(2)) {
		delta_angle = delta_angle + 45.0;
	}
	if (buttonHeld(3)) {
		delta_angle = delta_angle - 45.0;
	}

	rotation_angle = wrapf(rotation_angle + delta_angle * deltatime, 0.0, 360.0);

	float asrad = rad(rotation_angle);
	cam_pos.x = cos(asrad) * cam_radius;
	cam_pos.z = sin(asrad) * cam_radius;

	setCamPos(cam_pos);
}

void draw3D() {
	pushMatrix();
		// front
		texture(BRICK, 0, 64, 64);
		beginMesh(QUADS);
			vertColor(RED);
			vertUV((vec2){0.0, 0.0});
			vertex((vec3){-0.5, 0.5, 0.5});

			vertColor(GREEN);
			vertUV((vec2){0.0, 1.0});
			vertex((vec3){-0.5, -0.5, 0.5});

			vertColor(BLUE);
			vertUV((vec2){1.0, 1.0});
			vertex((vec3){0.5, -0.5, 0.5});

			vertColor(WHITE);
			vertUV((vec2){1.0, 0.0});
			vertex((vec3){0.5, 0.5, 0.5});
		endMesh();

		// left
		vec2 midpoint = (vec2){0.5, 0.5};
		texture(WOOD, 0, 64, 64);
		beginMesh(QUADS);
			vertColor(WHITE);
			vertUV(midpoint - (vec2){left_scale, left_scale});
			vertex((vec3){-0.5, 0.5, -0.5});

			vertUV(midpoint + (vec2){-left_scale, left_scale});
			vertex((vec3){-0.5, -0.5, -0.5});

			vertUV(midpoint + (vec2){left_scale, left_scale});
			vertex((vec3){-0.5, -0.5, 0.5});

			vertUV(midpoint + (vec2){left_scale, -left_scale});
			vertex((vec3){-0.5, 0.5, 0.5});
		endMesh();

		// right
		vec2 scrollv = (vec2){right_scroll, right_scroll};
		texture(TILE, 0, 64, 64);
		beginMesh(QUADS);
			vertColor(WHITE);
			vertUV((vec2){0.0, 0.0} + scrollv);
			vertex((vec3){0.5, 0.5, 0.5});

			vertColor(BLUE);
			vertUV((vec2){0.0, 1.0} + scrollv);
			vertex((vec3){0.5, -0.5, 0.5});

			vertColor(BLUE);
			vertUV((vec2){1.0, 1.0} + scrollv);
			vertex((vec3){0.5, -0.5, -0.5});

			vertColor(WHITE);
			vertUV((vec2){1.0, 0.0} + scrollv);
			vertex((vec3){0.5, 0.5, -0.5});
		endMesh();

		// back
		texture(0, 0, 64, 64);
		beginMesh(QUADS);
			vertColor(WHITE);
			vertUV((vec2){0.0, 0.0});
			vertex((vec3){0.5, 0.5, -0.5});

			vertUV((vec2){0.0, 1.0});
			vertex((vec3){0.5, -0.5, -0.5});

			vertUV((vec2){1.0, 1.0});
			vertex((vec3){-0.5, -0.5, -0.5});

			vertUV((vec2){1.0, 0.0});
			vertex((vec3){-0.5, 0.5, -0.5});
		endMesh();
	popMatrix();

	frames = frames + 1;
}
