name="monster"
./recorder --shader example/$name.glsl --output "render/$name" --fps 30 --count 400 --width 3840 --height 1600 --startframe 0 --norender \
--channel0cube "./textures/cubemap00/1.png" "./textures/cubemap00/2.png" "./textures/cubemap00/3.png" "./textures/cubemap00/4.png" "./textures/cubemap00/5.png" "./textures/cubemap00/6.png"
