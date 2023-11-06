void init() {
    setCam3DPosition(0, (vec3){0.0, 3.0, 6.0});

    int* objmap = (int*)(0x00F62000 + 84);
    objmap[0] = 1;
    objmap[1] = 0;
    objmap[2] = 94;
}

void draw() {
    clear(0x808080FF);
    camera3D(0);

    pushMatrix();
        rotate((vec3){0.0, wrapf(time() * 15.0, 0.0, 360.0), 0.0});

        texture(0, 64, 64, 64);
        drawObj(0);
        //drawObjEx(1, 0, 94);
    popMatrix();
}
