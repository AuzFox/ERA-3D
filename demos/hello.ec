// hello.ec by Auz
// this demo is a minimal example of how to render a rotating 3D triangle onto the screen

// establish some constants for readability
enum {

    // constant for disabling backface culling
    CULLING_DISABLED = 2,
    
    // constant for disabling textures
    TEXTURES_DISABLED = 2,

    // primitive mode for drawing triangles
    TRIANGLES = 1,

    // convenient color constants.
    // colors use the RGBA32 format
    BLACK = 0x000000FF,
    WHITE = 0xFFFFFFFF,
    RED   = 0xFF0000FF,
    GREEN = 0x00FF00FF,
    BLUE  = 0x0000FFFF,

    // screen and font dimentions
    SCREEN_WIDTH = 480,
    SCREEN_HEIGHT = 360,
    CHAR_WIDTH = 6,
    CHAR_HEIGHT = 9,
};

// create a 3D vector that will store the rotation of the triangle
vec3 rotation;

// this function is called once when the game starts,
// use it to set the initial state for your game
void init() {

    // disable backface culling and texturing for this demo
    // 
    // when texturing is disabled,
    // all pixels on a surface are set to white instead of using a texture
    setCullMode(CULLING_DISABLED);
    setTextureMode(TEXTURES_DISABLED);

    // set the x, y, and z rotation angles to zero
    rotation = vec3Zero();
}

// this function is called every frame,
// use it to update game state before rendering
void update(float delta_time) {

    // rotate the triangle along the y (vertical) axis at 45 degrees per second
    // 
    // wrapf() keeps the angle between 0.0 and 360.0
    rotation.y = wrapf(rotation.y + 45.0 * delta_time, 0.0, 360.0);
}

// this function is called after update() every frame,
// use it to draw objects to the screen
void draw() {

    // clear the screen to black
    clear(BLACK);

    // push a matrix onto the matrix stack
    // 
    // ERA-3D maintains a stack of matrices,
    // the matrix on top of the stack determines the
    // position, rotation, and scale of the geometry to be rendered
    // 
    // at the start of every frame, ERA-3D sets up a matrix configured to the view of
    // the default 3D camera (camera3D(0)).
    // the default 3D camera starts at position (0, 0, 4) and is looking at the origin (0, 0, 0)
    //
    // pushing a new matrix copies the previous matrix,
    // so we can modify the copy by translating, rotating, scaling, etc.
    // when we are done applying any transformations, we should pop the
    // current matrix off of the stack so the next object can use the
    // unmodified original matrix again for its own transformations
    pushMatrix();

        // apply rotation to the current matrix
        rotate(rotation);

        // begin constructing our mesh
        //
        // the argument to beginMesh determines the type of primitives we are constructing.
        // here, we are specifying that we want to construct triangles
        //
        // all possible primitive types are:
        //   0: LINES
        //   1: TRIANGLES
        //   2: QUADS
        beginMesh(TRIANGLES);

            // when creating primitives, we need to specify information about each
            // vertex that makes up the object.
            //
            // a vertex is a point in 3D space that also has additional information
            // attached to it.
            // vertices contain the following data:
            //   vertex color   : a tint color applied to the vertex
            //   vertex UV      : 2D coordinates for the part of the texture to sample from
            //   vertex normal  : a 3D vector that is for lighting
            //   vertex position: 3D coordinates for the vertex
            //
            // for this demo, we will ignore everything except for the colors and positions
            
            // establish a vertex color of red for the next vertex
            meshColor(RED);


            meshVertex((vec3){0.0, 1.0, 0.0});

            meshColor(GREEN);
            meshVertex((vec3){-1.0, -1.0, 0.0});

            meshColor(BLUE);
            meshVertex((vec3){1.0, -1.0, 0.0});

        // finalize the mesh
        endMesh();
    
    // pop the matrix off of the stack
    popMatrix();

    // switch to the default 2D camera for 2D drawing
    camera2D(0);

    // render some text in the center of the screen
    // 
    // the screen is 320x240 pixels
    //
    // each character is 6x9 pixels
    string text = "HELLO ERA-3D!";

    int x = (SCREEN_WIDTH / 2) - ((text.length * CHAR_WIDTH) / 2); // x screen position
    int y = (SCREEN_HEIGHT / 2) - (CHAR_HEIGHT / 2);               // y screen position
    print2D(x, y, WHITE, text);
}
