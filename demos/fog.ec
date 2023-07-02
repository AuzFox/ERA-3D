enum {
    BLACK = 0x000000FF,
    WHITE = 0xFFFFFFFF,
};

struct HallwaySegment {
    vec3 position;
};

vec3 cam_position;
vec3 cam_target;
float cam_target_offset;
vec3 cam_velocity;

HallwaySegment* hallway_segments;
int hallway_segments_count;

void init() {
    // configure fog
    setFogMode(1);
    setFogStart(4.0);
    setFogEnd(32.0);
    setFogColor(BLACK);

    // setup camera
    cam_position = (vec3){0.0, 2.5, 0.0};
    cam_target_offset = 0.0;
    cam_velocity = (vec3){0.0, 0.0, -2.0};

    // init hallway segments
    hallway_segments = 0x000000; // store segments at the beginning of the heap
    hallway_segments_count = 1;

    for (int i = 0; i < hallway_segments_count; i = i + 1) {
        HallwaySegment* segment = hallway_segments + i;

        segment -> position = (vec3){0.0, 0.0, (float)i * 5.0};
    }
}

void update(float delta_time) {
    cam_target_offset = sin(time());

    //cam_position = cam_position + cam_velocity * delta_time;

    cam_target = (vec3) {
        cam_target_offset,
        cam_position.y,
        cam_position.z + 2.5
    };

    setCamPos(cam_position);
    setCamTarget(cam_target);

    if (buttonHeld(2)) {
        setFogStart(getFogStart() - 8.0 * delta_time);
    }
    else if (buttonHeld(3)) {
        setFogStart(getFogStart() + 8.0 * delta_time);
    }

    if (buttonHeld(0)) {
        setFogEnd(getFogEnd() + 8.0 * delta_time);
    }
    else if (buttonHeld(1)) {
        setFogEnd(getFogEnd() - 8.0 * delta_time);
    }

    if (buttonDown(4)) {
        printf(getFogStart());
        printf(getFogEnd());
    }

    if (buttonDown(5)) {
        if (getFogColor() == BLACK) {
            setFogColor(WHITE);
        }
        else {
            setFogColor(BLACK);
        }
    }

    /*
    for (int i = 0; i < hallway_segments_count; i = i + 1) {
        HallwaySegment* segment = hallway_segments + i;

        vec3 center_of_segment = segment -> position + (vec3){0.0, 2.5, 0.0};

        float max_dist = 5.0 * 4.0;
        if (vec3DistSq(cam_position, center_of_segment) >= (max_dist * max_dist)) {
            segment -> position = cam_position - (vec3){0.0, 2.5, 0.0};
        }
    }
    */
}

void draw3D() {
    // draw hallway segments
    for (int i = 0; i < hallway_segments_count; i = i + 1) {
        HallwaySegment* segment = hallway_segments + i;

        pushMatrix();
            translate(segment -> position);
            
            // floor
            texture(0, 256, 16, 16);
            beginMesh(2);
                vertColor(0xFFFFFFFF);

                vertUV((vec2){0.0, 0.0});
                vertex((vec3){-200.5, 0, -200.5});
                vertUV((vec2){0.0, 1.0});
                vertex((vec3){-200.5, 0,  200.5});
                vertUV((vec2){1.0, 1.0});
                vertex((vec3){ 200.5, 0,  200.5});
                vertUV((vec2){1.0, 0.0});
                vertex((vec3){ 200.5, 0, -200.5});
            endMesh();
        popMatrix();
    }
}
