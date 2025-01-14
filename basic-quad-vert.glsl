#version 450 core

layout (location = 0) in vec2 aPos;
layout (location = 1) in vec2 aTexCoord;  // 输入的纹理坐标

out vec2 TexCoord;  // 传递到片段着色器的纹理坐标

void main()
{
    // 这里的变换矩阵是单位矩阵，顶点位置直接映射到裁剪空间 [-1, 1]
    gl_Position = vec4(aPos, 0.0, 1.0);
    TexCoord = aTexCoord;  // 传递纹理坐标给片段着色器
}
