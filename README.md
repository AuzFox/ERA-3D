# ERA-3D

ERA-3D is a 3D fantasy console inspired by 5th generation video game consoles such as the Nintendo 64 and Sony Playstation.

> [!WARNING]
> ERA-3D is still in early development, expect unfinished UI and missing features!

## Specifications
```
Display:   640x360
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

For building instructions, see the [Building](https://auzfox.github.io/ERA-3D-Docs/building/) page of the documentation.

## Libraries Used
- [raylib v5.0](https://github.com/raysan5/raylib)
- [Raylib.nelua](https://github.com/AuzFox/Raylib.nelua)
- [BlipKit](https://github.com/detomon/BlipKit)
- [zip](https://github.com/kuba--/zip)
- fs and json from [nelua-batteries](https://github.com/edubart/nelua-batteries)

## License

ERA-3D is licensed under the zlib license.
See the `LICENSE` file for the full license text.
