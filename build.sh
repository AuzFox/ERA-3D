# exit the script on any error
set -e

# BUILD FUNCTIONS

buildSetup() {
    # download E3DBlipKit repo
    echo "cloning E3DBlipKit..."
    git clone https://github.com/AuzFox/E3DBlipKit.git src/third_party/blipkit/E3DBlipKit
    echo "done"

    # download raylib 5.5 repo
    echo "cloning raylib 5.5..."
    git clone --depth 1 --branch 5.5 https://github.com/raysan5/raylib.git src/third_party/raylib/raylib
    echo "done"

    # create ERA-3D build folders
    echo "creating ERA-3D build folders..."
    mkdir -p build/include/blipkit
    mkdir -p build/lib
    echo "done"
}

buildE3DBlipKit() {
    # enter E3DBlipKit folder
    cd src/third_party/blipkit/E3DBlipKit

    # make E3DBlipKit build folder
    echo "creating E3DBlipKit build folder..."
    mkdir build
    cd build
    echo "done"

    # build E3DBlipKit
    echo "compiling E3DBlipKit..."
    if [ $os = 'windows' ]; then
        cmake -G "MinGW Makefiles" ..
    else
        cmake ..
    fi
    make
    echo "done"

    # copy files to ERA-3D build folder
    echo "copying E3DBlipKit files to ERA-3D build folder..."
    cp ../src/*.h ../../../../../build/include/blipkit
    cp src/libblipkit.a ../../../../../build/lib
    echo "done"

    # exit E3DBlipKit folder
    cd ../../../../../
}

buildRaylib() {
    # enter raylib folder
    cd src/third_party/raylib/raylib/src

    # build raylib
    echo "compiling raylib..."
    make
    echo "done"

    # copy files to ERA-3D build folder
    echo "copying raylib files to ERA-3D build folder..."
    cp raylib.h ../../../../../build/include/
    cp raymath.h ../../../../../build/include/
    cp rlgl.h ../../../../../build/include/
    cp libraylib.a ../../../../../build/lib
    echo "done"

    # exit raylib folder
    cd ../../../../../
}

buildERA3D() {
    nelua -C -V --cflags="-I build/include -L build/lib" --release src/main.nelua -o era-3d
}

cleanBuildDirs() {
    if [ -e build/ ]; then
        rm -r -f build/
    fi
    
    if [ -e src/third_party/blipkit/E3DBlipKit ]; then
        rm -r -f src/third_party/blipkit/E3DBlipKit
    fi

    if [ -e src/third_party/raylib/raylib ]; then
        rm -r -f src/third_party/raylib/raylib
    fi
}

# MAIN SCRIPT

# check arguments
if [ $# -eq 0 ]; then
    echo "USAGE: ./build.sh linux/windows/clean"
else
    os=$1
    if [ $os = 'linux' ] || [ $os = 'windows' ]; then
        echo "starting build..."
        buildSetup
        echo "done starting build"

        echo "building E3DBlipKit..."
        buildE3DBlipKit
        echo "done building E3DBlipKit"
        
        echo "building raylib..."
        buildRaylib
        echo "done building raylib"

        echo "building ERA-3D..."
        buildERA3D
        echo "done building ERA-3D"
        
        echo "ERA-3D built successfully"
    elif [ $os = 'clean' ]; then
        echo "cleaning build folders..."
        cleanBuildDirs
        echo "done cleaning build folders"
    else
        echo "invalid OS '$os', must be 'linux' or 'windows'"
    fi
fi
