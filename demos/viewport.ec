enum {
    SCREEN_W = 320,
    SCREEN_H = 240,

    SUBVIEW_W = 64,
    SUBVIEW_H = 64,

    // ERA-3D has 4 built-in cameras
    //
    // use camera 0 for the main screen and cameras 1-3 for the sub-views
    SUBVIEW_COUNT = 3
};

// store data for the sub-views
//
// position, velocity, clear+fog color
vec2 positions[SUBVIEW_COUNT];
vec2 velocities[SUBVIEW_COUNT];
int colors[SUBVIEW_COUNT];

// draw a quad, used by draw_cube()
void draw_cube_face() {
    vertUV((vec2){0.0, 0.0});
    vertex((vec3){-0.5, 0.5, 0.5});
    vertUV((vec2){0.0, 1.0});
    vertex((vec3){-0.5, -0.5, 0.5});
    vertUV((vec2){1.0, 1.0});
    vertex((vec3){0.5, -0.5, 0.5});
    vertUV((vec2){1.0, 0.0});
    vertex((vec3){0.5, 0.5, 0.5});
}

// draw a rotating cube
void draw_cube() {
    vec3 rotation_values[6]; // rotations for each face from identity position

    rotation_values[0] = (vec3){  0.0,   0.0, 0.0}; // front
    rotation_values[1] = (vec3){  0.0,  90.0, 0.0}; // left
    rotation_values[2] = (vec3){  0.0, -90.0, 0.0}; // right
    rotation_values[3] = (vec3){  0.0, 180.0, 0.0}; // back
    rotation_values[4] = (vec3){-90.0,   0.0, 0.0}; // top
    rotation_values[5] = (vec3){ 90.0,   0.0, 0.0}; // bottom

    texture(64, 0, 64, 64);

    pushMatrix();
        rotate((vec3){wrapf(time() * -22.5, 0.0, 360.0), wrapf(time() * -45.0, 0.0, 360.0), 0.0});
		
		beginMesh(2);
			vertColor(0xFFFFFFFF);

            // draw faces
            for (int i = 0; i < 6; i = i + 1) {
                pushMatrix();
                    rotate(rotation_values[i]);
                    draw_cube_face();
                popMatrix();
            }
		endMesh();
    popMatrix();
}

void init () {
    // configure render settings
    // sub-views do not change these values in this demo
    setFogMode(1);
	setFogStart(2.0);
	setFogEnd(2.5);

    setCamPos(0, (vec3){0.0, 0.0, 2.5}); // position main camera to look at it's cube

    // init sub-view data
    //
    // start each sub-view in the middle of the screen
    // give them random speeds and colors
    // position their cameras to look at the cube
    for (int i = 0; i < SUBVIEW_COUNT; i = i + 1) {
        positions[i] = (vec2){
            (SCREEN_W / 2.0) - (SUBVIEW_W / 2),
            (SCREEN_H / 2.0) - (SUBVIEW_H / 2)
        };

        velocities[i] = (vec2){
            randf(-64.0, 64.0),
            randf(-64.0, 64.0)
        };

        colors[i] = randiEx() | 0xFF;

        setCamPos(i + 1, (vec3){0, 0, 2.5}); // i + 1 to skip camera 0
    }
}

void update(float delta_time) {
    // update sub-view positions and velocities
    // when a sub-view reaches a screen edge, they bounce
    for (int i = 0; i < SUBVIEW_COUNT; i = i + 1) {
        vec2* pos = &positions[i];
        vec2* vel = &velocities[i];

        pos -> x = pos -> x + vel -> x * delta_time;
        pos -> y = pos -> y + vel -> y * delta_time;

        if ((int)pos -> x < 0) {
            pos -> x = 0.0;
            vel -> x = -(vel -> x);
        }
        else if ((int)pos -> x > (SCREEN_W - SUBVIEW_W)) {
            pos -> x = ((float)SCREEN_W - (float)SUBVIEW_W);
            vel -> x = -(vel -> x);
        }

        if ((int)pos -> y < 0) {
            pos -> y = 0.0;
            vel -> y = -(vel -> y);
        }
        else if ((int)pos -> y > (SCREEN_H - SUBVIEW_H)) {
            pos -> y = ((float)SCREEN_H - (float)SUBVIEW_H);
            vel -> y = -(vel -> y);
        }
    }
}

void draw3D() {
    // draw main viewport
    viewport(0, 0, 320, 240);
    clear(0x000000FF);
    setFogColor(0x000000FF);
    camera3D(0);

    draw_cube();

    // draw sub-views
    for (int i = 0; i < SUBVIEW_COUNT; i = i + 1) {
        vec2 pos = positions[i];
        vec2 vel = velocities[i];
        int col = colors[i];

        viewport((int)pos.x, (int)pos.y, SUBVIEW_W, SUBVIEW_H);
        clear(col);
        setFogColor(col);
        camera3D(i + 1);

        draw_cube();
    }
}
