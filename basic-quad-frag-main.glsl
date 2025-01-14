in vec2 TexCoord;  // 从顶点着色器传来的纹理坐标

out vec4 FragColor;  // 输出的颜色值

void main()
{
    // 直接从纹理中获取颜色，绘制整个屏幕的图像
    mainImage(FragColor, TexCoord * iResolution.xy);
}
