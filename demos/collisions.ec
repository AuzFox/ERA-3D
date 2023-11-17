enum {
    BALL_COUNT = 64,

    OBJMEM_ADDR = 0x00C00000
};

struct Ball {
    colaabb aabb;
    vec3 direction;
};

float SPEED;
colaabb col_front_wall;
colaabb col_back_wall;
colaabb col_left_wall;
colaabb col_right_wall;
colaabb col_ceiling;
colaabb col_floor;
Ball* balls;

void init() {
    SPEED = 8.0;

    // load cube model data into OBJMEM
    vertex* objmem = (vertex*)OBJMEM_ADDR;
    objmem[ 0] = (vertex){(vec3){ 1.0,  1.0, -1.0}, vec3Zero(), (vec2){0.0, 0.0}, 0xFFFFFFFF}; // back
    objmem[ 1] = (vertex){(vec3){ 1.0, -1.0, -1.0}, vec3Zero(), (vec2){0.0, 1.0}, 0x808080FF};
    objmem[ 2] = (vertex){(vec3){-1.0, -1.0, -1.0}, vec3Zero(), (vec2){1.0, 1.0}, 0x808080FF};
    objmem[ 3] = (vertex){(vec3){-1.0,  1.0, -1.0}, vec3Zero(), (vec2){1.0, 0.0}, 0xFFFFFFFF};
    objmem[ 4] = (vertex){(vec3){-1.0,  1.0, -1.0}, vec3Zero(), (vec2){0.0, 0.0}, 0xFFFFFFFF}; // left
    objmem[ 5] = (vertex){(vec3){-1.0, -1.0, -1.0}, vec3Zero(), (vec2){0.0, 1.0}, 0x808080FF};
    objmem[ 6] = (vertex){(vec3){-1.0, -1.0,  1.0}, vec3Zero(), (vec2){1.0, 1.0}, 0x808080FF};
    objmem[ 7] = (vertex){(vec3){-1.0,  1.0,  1.0}, vec3Zero(), (vec2){1.0, 0.0}, 0xFFFFFFFF};
    objmem[ 8] = (vertex){(vec3){ 1.0,  1.0,  1.0}, vec3Zero(), (vec2){0.0, 0.0}, 0xFFFFFFFF}; // right
    objmem[ 9] = (vertex){(vec3){ 1.0, -1.0,  1.0}, vec3Zero(), (vec2){0.0, 1.0}, 0x808080FF};
    objmem[10] = (vertex){(vec3){ 1.0, -1.0, -1.0}, vec3Zero(), (vec2){1.0, 1.0}, 0x808080FF};
    objmem[11] = (vertex){(vec3){ 1.0,  1.0, -1.0}, vec3Zero(), (vec2){1.0, 0.0}, 0xFFFFFFFF};
    objmem[12] = (vertex){(vec3){-1.0,  1.0, -1.0}, vec3Zero(), (vec2){0.0, 0.0}, 0xFFFFFFFF}; // top
    objmem[13] = (vertex){(vec3){-1.0,  1.0,  1.0}, vec3Zero(), (vec2){0.0, 1.0}, 0xFFFFFFFF};
    objmem[14] = (vertex){(vec3){ 1.0,  1.0,  1.0}, vec3Zero(), (vec2){1.0, 1.0}, 0xFFFFFFFF};
    objmem[15] = (vertex){(vec3){ 1.0,  1.0, -1.0}, vec3Zero(), (vec2){1.0, 0.0}, 0xFFFFFFFF};
    objmem[16] = (vertex){(vec3){-1.0, -1.0,  1.0}, vec3Zero(), (vec2){0.0, 0.0}, 0x808080FF}; // bottom
    objmem[17] = (vertex){(vec3){-1.0, -1.0, -1.0}, vec3Zero(), (vec2){0.0, 1.0}, 0x808080FF};
    objmem[18] = (vertex){(vec3){ 1.0, -1.0, -1.0}, vec3Zero(), (vec2){1.0, 1.0}, 0x808080FF};
    objmem[19] = (vertex){(vec3){ 1.0, -1.0,  1.0}, vec3Zero(), (vec2){1.0, 0.0}, 0x808080FF};
    objmem[20] = (vertex){(vec3){-1.0,  1.0,  1.0}, vec3Zero(), (vec2){0.0, 0.0}, 0xFFFFFFFF}; // front
    objmem[21] = (vertex){(vec3){-1.0, -1.0,  1.0}, vec3Zero(), (vec2){0.0, 1.0}, 0x808080FF};
    objmem[22] = (vertex){(vec3){ 1.0, -1.0,  1.0}, vec3Zero(), (vec2){1.0, 1.0}, 0x808080FF};
    objmem[23] = (vertex){(vec3){ 1.0,  1.0,  1.0}, vec3Zero(), (vec2){1.0, 0.0}, 0xFFFFFFFF};

    col_front_wall = (colaabb){1, (vec3){ 0.0,  0.0,  9.0}, 16.0, 16.0,  2.0};
    col_back_wall  = (colaabb){1, (vec3){ 0.0,  0.0, -9.0}, 16.0, 16.0,  2.0};
    col_left_wall  = (colaabb){1, (vec3){-9.0,  0.0,  0.0},  2.0, 16.0, 16.0};
    col_right_wall = (colaabb){1, (vec3){ 9.0,  0.0,  0.0},  2.0, 16.0, 16.0};
    col_ceiling    = (colaabb){1, (vec3){ 0.0,  9.0,  0.0}, 16.0,  2.0, 16.0};
    col_floor      = (colaabb){1, (vec3){ 0.0, -9.0,  0.0}, 16.0,  2.0, 16.0};

    balls = (Ball*)0;
    for (int i = 0; i < BALL_COUNT; i = i + 1) {
        balls[i] = (Ball){
            (colaabb){1, vec3Zero(), 1.0, 1.0, 1.0},
            vec3Normalize((vec3){randf(-1.0, 1.0), randf(-1.0, 1.0), randf(-1.0, 1.0)})
        };
    }
    setCam3DPosition(0, (vec3){0.0, 0.0, 32.0});
}

void update(float delta_time) {
    float delta_speed = SPEED * delta_time;

    for (int i = 0; i < BALL_COUNT; i = i + 1) {
        Ball ball = balls[i];

        ball.aabb.position = (ball.aabb.position) + ((ball.direction) * delta_speed);

        // check collisions
        if (checkCollision(&col_front_wall, &ball.aabb)) {
            // reflect z
            ball.aabb.position.z = 7.5;
            ball.direction.z = -(ball.direction.z);
        }
        else if (checkCollision(&col_back_wall, &ball.aabb)) {
            // reflect z
            ball.aabb.position.z = -7.5;
            ball.direction.z = -(ball.direction.z);
        }
        if (checkCollision(&col_left_wall, &ball.aabb)) {
            // reflect x
            ball.aabb.position.x = -7.5;
            ball.direction.x = -(ball.direction.x);
        }
        else if (checkCollision(&col_right_wall, &ball.aabb)) {
            // reflect x
            ball.aabb.position.x = 7.5;
            ball.direction.x = -(ball.direction.x);
        }
        if (checkCollision(&col_ceiling, &ball.aabb)) {
            // reflect y
            ball.aabb.position.y = 7.5;
            ball.direction.y = -(ball.direction.y);
        }
        else if (checkCollision(&col_floor, &ball.aabb)) {
            // reflect y
            ball.aabb.position.y = -7.5;
            ball.direction.y = -(ball.direction.y);
        }

        balls[i] = ball;
    }
}

void draw() {
    clear(0x808080FF);
    camera3D(0);

    // draw room
    setCullMode(1);
    pushMatrix();
        scale((vec3){8.0, 8.0, 8.0});
        texture(0, 0, 16, 16);
        drawObjEx(2, 0, 6);
    popMatrix();
    setCullMode(0);

    setTextureMode(2);
    // draw balls and shadows
    pushMatrix();
        for (int i = 0; i < BALL_COUNT; i = i + 1) {
            vec3 p = balls[i].aabb.position;

            identity();
            translate(p);
            scale((vec3){0.5, 0.5, 0.5});
            drawObjEx(2, 0, 6);

            p.y = -7.9;

            identity();
            translate(p);
            beginMesh(2);
                meshColor(0x000000FF);
                meshUV((vec2){0.0, 0.0});
                meshVertex((vec3){-0.5, 0.0, -0.5});
                meshUV((vec2){0.0, 1.0});
                meshVertex((vec3){-0.5, 0.0, 0.5});
                meshUV((vec2){1.0, 1.0});
                meshVertex((vec3){0.5, 0.0, 0.5});
                meshUV((vec2){1.0, 0.0});
                meshVertex((vec3){0.5, 0.0, -0.5});
            endMesh();
        }
    popMatrix();
    setTextureMode(0);
}
