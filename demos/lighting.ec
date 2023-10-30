enum {
    LIGHT_COUNT = 4,
    LIGHT_POINT = 0,
    LIGHT_DIRECTIONAL,

    RED   = 0xFF0000FF,
    GREEN = 0x00FF00FF,
    BLUE  = 0x0000FFFF,
    WHITE = 0xFFFFFFFF,
};

struct Light {
    // lighting system attributes
    int enabled;
    int type;
    float radius;
    vec3 position;
    vec3 direction;
    int color;

    // additional data
    float rotation_angle;
    float rotation_radius;
};

Light lights[LIGHT_COUNT];

void updateLights() {
    for (int i = 0; i < LIGHT_COUNT; i = i + 1) {
        Light* light = lights + i;

        setLightEnabled(i, light->enabled);
        setLightType(i, light->type);

        if (light->type == LIGHT_POINT) {
            setLightRadius(i, light->radius);
            setLightPosition(i, light->position);
        }
        else {
            setLightDirection(i, light->direction);
        }

        setLightColor(i, light->color);
    }
}

void makeQuad() {
    meshNormal((vec3){0.0, 0.5, 0.0});

    meshUV((vec2){0.0, 0.0});
    meshVertex((vec3){-0.5, 0.0, -0.5});
    meshUV((vec2){0.0, 1.0});
    meshVertex((vec3){-0.5, 0.0, 0.5});
    meshUV((vec2){1.0, 1.0});
    meshVertex((vec3){0.5, 0.0, 0.5});
    meshUV((vec2){1.0, 0.0});
    meshVertex((vec3){0.5, 0.0, -0.5});
}

void init() {
    setAmbientFactor(10.0);
    setAmbientColor(WHITE);

    lights[0] = (Light){true, LIGHT_POINT, 4.0, (vec3){0.0, 1.0, 0.0}, vec3Zero(), RED  ,   0.0, 2.0};
    lights[1] = (Light){true, LIGHT_POINT, 4.0, (vec3){0.0, 1.0, 0.0}, vec3Zero(), GREEN,  90.0, 2.0};
    lights[2] = (Light){true, LIGHT_POINT, 4.0, (vec3){0.0, 1.0, 0.0}, vec3Zero(), BLUE , 180.0, 2.0};
    lights[3] = (Light){true, LIGHT_POINT, 4.0, (vec3){0.0, 1.0, 0.0}, vec3Zero(), WHITE, 270.0, 2.0};
    
    setCam3DPosition(0, (vec3){6.0, 3.0, 6.0});
}

void update(float delta_time) {
    for (int i = 0; i < LIGHT_COUNT; i = i + 1) {
        Light* light = lights + i;

        light->rotation_angle = wrapf(light->rotation_angle + 45.0 * delta_time, 0.0, 360.0);
        
        float asrad = rad(light->rotation_angle);
        light->position.x = cos(asrad) * (light->rotation_radius);
        light->position.z = sin(asrad) * (light->rotation_radius);
    }

    updateLights();
}

void draw() {
    clear(0x000000FF);
    camera3D(0);

    setTextureMode(2);
    pushMatrix();
        beginMesh(2);
            for (int i = 0; i < LIGHT_COUNT; i = i + 1) {
                Light* light = lights + i;

                identity();
                translate(light->position);
                meshColor(light->color);
                meshVertex((vec3){0.0, 0.1, 0.0});
                meshVertex((vec3){-0.1, 0.0, 0.0});
                meshVertex((vec3){0.0, -0.1, 0.0});
                meshVertex((vec3){0.1, 0.0, 0.0});
            }
        endMesh();
    popMatrix();

    setLightingMode(true);
    pushMatrix();
        //texture(0, 64, 64, 64);
        drawModelEx(1, 0, 94);
    popMatrix();

    pushMatrix();
        //texture(192, 0, 64, 64);
        beginMesh(2);
            for (int z = -2; z < 3; z = z + 1) {
                for (int x = -2; x < 3; x = x + 1) {
                    identity();
                    translate((vec3){(float)x, -1.0, (float)z});
                    makeQuad();
                }
            }
        endMesh();
    popMatrix();
    setLightingMode(false);
    setTextureMode(0);
}
