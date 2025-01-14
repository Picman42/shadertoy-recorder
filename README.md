# Usage
- `--shader`: Shadertoy file path.
- `--output`: (OPTIONAL) PNG output path. Default is working directory.
- `--fps`: (OPTIONAL) Framerate. Default is 30.
- `--count`: (OPTIONAL) Frame count. Default is 30.
- `--startframe`: (OPTIONAL) Starting frame index. Default is 0.
- `--width`: (OPTIONAL) Image width. Default is 1920.
- `--height`: (OPTIONAL) Image height. Default is 1080.
- `--norender`: (OPTIONAL) Do not render to files. Used to view animation.

# Uniforms
Currently only implemented `iTime, iResolution, iFrame, iFramerate`.

# Compilation
- Linux: `g++ recorder.cpp -o recorder -lGL -lGLEW -lglfw`
