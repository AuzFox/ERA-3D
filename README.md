# ERA-3D

ERA-3D is a 3D fantasy console inspired by 5th generation video game consoles such as the Nintendo 64 and Sony Playstation.

> [!WARNING]
> ERA-3D is still in early development, expect unfinished UI and missing features!

## Specifications
```
Display:   480x360
Memory:    8MiB general purpose RAM, memory-mapped assets (textures, audio, models)
Textures:  1024x1024 RGBA32 texture atlas, maximum individual texture size of 256x256
Rendering: Maximum of ~16k triangles per frame*, OpenGL 1.1 fixed-function style graphics API
Audio:     8 tracks, 16bit 22050hz stereo audio sample playback
Scripting: Custom langauge similar to C

*Triangle rendering limit is subject to change
```

## Documentation

Check out the [ERA-3D Docs](https://auzfox.github.io/ERA-3D-Docs/)!

## Building

To build ERA-3D, you must first [install Nelua](https://nelua.io/installing/).
Follow the installation instructions on the Nelua website.

Once Nelua is installed, install the following C libraries:
- [raylib v5.0](https://github.com/raysan5/raylib)
- [BlipKit](https://github.com/detomon/BlipKit)
- [zip](https://github.com/kuba--/zip)

Once all dependencies are installed, clone this repository and run the following commands:
```
cd .../ERA-3D/
nelua --release src/main.nelua -o era-3d
```
You should now have the `era-3d` executable.
move `era-3d` and the `assets` directory to the desired install location.

## Libraries Used
- [raylib v5.0](https://github.com/raysan5/raylib)
- [Raylib.nelua](https://github.com/AuzFox/Raylib.nelua)
- [BlipKit](https://github.com/detomon/BlipKit)
- [zip](https://github.com/kuba--/zip)
- fs and json from [nelua-batteries](https://github.com/edubart/nelua-batteries)

## License

ERA-3D is licensed under the zlib license.
See the `LICENSE` file for the full license text.
