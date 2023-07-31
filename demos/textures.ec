enum {
	// primitive geometry modes
	LINES = 0,
	TRIANGLES,
	QUADS,

	// color constants (RGBA32)
	ALPHA = 0x00000000,
	BLACK = 0x000000FF,
	WHITE = 0xFFFFFFFF,
	RED   = 0xFF0000FF,
	GREEN = 0x00FF00FF,
	BLUE  = 0x0000FFFF,

	// buttons (emulates a PS1-style controller)
	BTN_UP = 0,
	BTN_DOWN,
	BTN_LEFT,
	BTN_RIGHT,
	BTN_TRIANGLE,
	BTN_CROSS,
	BTN_SQUARE,
	BTN_CIRCLE
};

// this demo shows off some texture fx:
// front: normal with vertex colors
// left: scale 0.5-1.5x
// right: scroll
// back: transparent

float left_scale;
float right_scroll;
float rotation_angle;
float cam_radius;
vec3 cam_pos;

void init() {
	// init variables
	right_scroll = 0.0;
	rotation_angle = 90.0;
	cam_radius = 2.5;
	cam_pos = vec3Zero();

	// configure render settings
	setCullMode(2);     // 0 = cull backfaces, 1 = cull frontfaces, 2 = disable culling
	setFogMode(0);      // 1 = enable, 0 = disable
	setFogStart(2.0);   // 0.0 to 1000.0
	setFogEnd(2.5);     // 0.0 to 1000.0
	setFogColor(ALPHA); // RGBA32, can be transparent!
}

void update(float delta_time) {
	left_scale = 1.0 - 0.5 * sin(time());
	right_scroll = wrapf(right_scroll + 0.25 * delta_time, 0.0, 1.0);

	// toggle fog
	if (pressed(BTN_CROSS, 0)) {
		setFogMode(!getFogMode());
	}

	// rotate camera around cube
	float delta_angle = 0.0;
	if (held(BTN_LEFT, 0)) {
		delta_angle = delta_angle + 45.0;
	}
	if (held(BTN_RIGHT, 0)) {
		delta_angle = delta_angle - 45.0;
	}

	rotation_angle = wrapf(rotation_angle + delta_angle * delta_time, 0.0, 360.0);

	float asrad = rad(rotation_angle);
	cam_pos.x = cos(asrad) * cam_radius;
	cam_pos.z = sin(asrad) * cam_radius;

	setCamPos(0, cam_pos);
}

void draw() {
	clear(BLACK);

	pushMatrix();
		// front
		texture(64, 0, 64, 64);
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
		texture(128, 0, 64, 64);
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
		texture(192, 0, 64, 64);
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
}
