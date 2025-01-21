# Usage
- `--shader`: Shadertoy file path.
- `--output`: (OPTIONAL) PNG output path. Default is working directory.
- `--fps`: (OPTIONAL) Framerate. Default is 30.
- `--count`: (OPTIONAL) Frame count. Default is 30.
- `--startframe`: (OPTIONAL) Starting frame index. Default is 0.
- `--width`: (OPTIONAL) Image width. Default is 1920.
- `--height`: (OPTIONAL) Image height. Default is 1080.
- `--norender`: (OPTIONAL) Do not render to files. Used to view animation.
- `--channel{0|1|2|3}`: (OPTIONAL) 2D Texture paths for 4 channels.
- `--channel{0|1|2|3}cube`: (OPTIONAL) Cube Texture paths for 4 channels. Followed by 6 arguments.
- `--filter`: (OPTIONAL) Set filter mode. Options are `linear, nearest, mipmap`. Default is `linear`.
- `--wrap`: (OPTIONAL) Set filter mode. Options are `repeat, clamp, mirror, clear`. Default is `repeat`.

# Uniforms
Currently only implemented `iTime, iResolution, iFrame, iFrameratem, iChannel`.

# Compilation
- Linux: `g++ recorder.cpp -o recorder -lGL -lGLEW -lglfw`

# Note
Multiple buffers are currently not supported.
