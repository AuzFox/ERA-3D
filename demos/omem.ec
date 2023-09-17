struct Vertex {
    vec3 pos;
    vec3 norm;
    vec2 uv;
    int col;
};

void init() {
    setCullMode(2);

    // upload model data to OMEM
    Vertex* omem = (Vertex*)0x00C00000;
    omem[0] = (Vertex){(vec3){-1.0,  1.0, 0.0}, (vec3){0.0, 0.0, 1.0}, (vec2){0.0, 0.0}, 0xFFFFFFFF};
    omem[1] = (Vertex){(vec3){-1.0, -1.0, 0.0}, (vec3){0.0, 0.0, 1.0}, (vec2){0.0, 1.0}, 0xFFFFFFFF};
    omem[2] = (Vertex){(vec3){ 1.0, -1.0, 0.0}, (vec3){0.0, 0.0, 1.0}, (vec2){1.0, 1.0}, 0xFFFFFFFF};

    omem[3] = (Vertex){(vec3){ 1.0, -1.0, 0.0}, (vec3){0.0, 0.0, 1.0}, (vec2){1.0, 1.0}, 0xFF0000FF};
    omem[4] = (Vertex){(vec3){ 1.0,  1.0, 0.0}, (vec3){0.0, 0.0, 1.0}, (vec2){1.0, 0.0}, 0xFF0000FF};
    omem[5] = (Vertex){(vec3){-1.0,  1.0, 0.0}, (vec3){0.0, 0.0, 1.0}, (vec2){0.0, 0.0}, 0xFF0000FF};
}

void draw() {
    clear(0x000000FF);

    pushMatrix();
        rotate((vec3){0.0, wrapf(time() * 45.0, 0.0, 360.0), 0.0});
        drawModel(3, 1);
    popMatrix();
}
