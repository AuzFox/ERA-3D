void init() {
    setCam3DPosition(0, (vec3){0.0, 3.0, 6.0});
}

void draw() {
    clear(0x808080FF);
    camera3D(0);

    pushMatrix();
        rotate((vec3){0.0, wrapf(time() * 15.0, 0.0, 360.0), 0.0});

        texture(0, 64, 64, 64);
        drawModelEx(1, 0, 94);
    popMatrix();
}
