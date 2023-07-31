enum {
    SCREEN_W = 320,
    SCREEN_H = 240,

    SUBSCREEN_W = 160,
    SUBSCREEN_H = 120,

    // ERA-3D has 4 built-in cameras
    //
    // use one camera for each subscreen
    SUBSCREEN_COUNT = 4
};

struct vec2i {
    int x;
    int y;
};

struct subscreen {
    vec3 rotation_mask;
    vec2i position;
    int color;
    int camera;
};

// rotations for each cube face from identity position (used by draw_cube())
vec3 face_rotations[6];

// store data for the subscreens
subscreen subscreens[SUBSCREEN_COUNT];

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

// draw a rotated cube
void draw_cube(vec3 rotation) {
    texture(64, 0, 64, 64);

    pushMatrix();
        rotate(rotation);
		
		beginMesh(2);
			vertColor(0xFFFFFFFF);

            // draw faces
            for (int i = 0; i < 6; i = i + 1) {
                pushMatrix();
                    rotate(face_rotations[i]);
                    draw_cube_face();
                popMatrix();
            }
		endMesh();
    popMatrix();
}

void init() {
    // configure render settings
    // sub-views do not change these values in this demo
    setFogMode(1);
	setFogStart(2.0);
	setFogEnd(2.5);

    face_rotations[0] = (vec3){  0.0,   0.0, 0.0}; // front
    face_rotations[1] = (vec3){  0.0,  90.0, 0.0}; // left
    face_rotations[2] = (vec3){  0.0, -90.0, 0.0}; // right
    face_rotations[3] = (vec3){  0.0, 180.0, 0.0}; // back
    face_rotations[4] = (vec3){-90.0,   0.0, 0.0}; // top
    face_rotations[5] = (vec3){ 90.0,   0.0, 0.0}; // bottom

    subscreens[0] = (subscreen){(vec3){1.0, 1.0, 1.0}, (vec2i){          0, 0          }, 0xFFFFFFFF, 0};
    subscreens[1] = (subscreen){(vec3){1.0, 0.0, 0.0}, (vec2i){SUBSCREEN_W, 0          }, 0xFF0000FF, 1};
    subscreens[2] = (subscreen){(vec3){0.0, 1.0, 0.0}, (vec2i){          0, SUBSCREEN_H}, 0x00FF00FF, 2};
    subscreens[3] = (subscreen){(vec3){0.0, 0.0, 1.0}, (vec2i){SUBSCREEN_W, SUBSCREEN_H}, 0x0000FFFF, 3};

    // init subscreen cameras
    for (int i = 0; i < SUBSCREEN_COUNT; i = i + 1) {
        setCamPos(i, (vec3){0, 0, 2.5});
    }
}

void draw() {
    float angle = wrapf(time() * -45.0, 0.0, 360.0);
    vec3 rotation = (vec3){angle, angle, angle};
    
    // draw subscreens
    for (int i = 0; i < SUBSCREEN_COUNT; i = i + 1) {
        subscreen* screen = &subscreens[i];

        viewport(screen -> position.x, screen -> position.y, SUBSCREEN_W, SUBSCREEN_H);
        clear(screen -> color);
        setFogColor(screen -> color);
        camera3D(screen -> camera);
        draw_cube(rotation * (screen -> rotation_mask));
    }
}
