# texture="shadertoy10.png"
texture="custom/rd-bordered.png"
./recorder --shader example/nyan2.glsl --output "render/nyan2" --fps 30 --count 400 --width 3840 --height 1600 --startframe 100 --filter "mipmap" --norender \
--channel0 "./textures/$texture"
