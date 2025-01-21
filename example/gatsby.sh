name="gatsby"
cubemapFolder="./textures/cubemap01"
cubemapSuffix="jpg"
./recorder --shader example/$name.glsl --output "render/$name" --fps 30 --count 400 --width 3840 --height 1600 --startframe 0 \
--channel1 "./textures/shadertoy08.jpg" \
--channel0cube "$cubemapFolder/1.$cubemapSuffix" "$cubemapFolder/2.$cubemapSuffix" "$cubemapFolder/3.$cubemapSuffix" "$cubemapFolder/4.$cubemapSuffix" "$cubemapFolder/5.$cubemapSuffix" "$cubemapFolder/6.$cubemapSuffix"
