void init() {
    int* wavmap = (int*)(0x00F63854);
    wavmap[0] = 0;
    wavmap[1] = 2048;
}

void update(float delta_time) {
    if (pressed(0, 5)) {
        playWav(0, 0, 0xFE);
    }
}

void draw() {
    clear(0x000000FF);
    camera2D(0);

    print2D(0, 9, 0xFFFFFFFF, "PRESS [X] TO PLAY SAMPLE!");
}