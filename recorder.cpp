#include <GL/glew.h>
#include <GLFW/glfw3.h>
// #include <glad/glad.h>
#include <iostream>
#include <fstream>
#include <sstream>
#include <iomanip>
#include <string>
#include <vector>
#include <map>
#define STB_IMAGE_WRITE_IMPLEMENTATION
#include "stb_image/stb_image_write.h"

int width = 1920;
int height = 1080;

std::string loadShader(const std::string& filePath) {
    std::ifstream file(filePath);
    std::stringstream buffer;
    buffer << file.rdbuf();
    return buffer.str();
}

GLuint compileShader(const std::string& shaderCode, GLenum shaderType) {
    GLuint shader = glCreateShader(shaderType);
    const char* code = shaderCode.c_str();
    glShaderSource(shader, 1, &code, nullptr);
    glCompileShader(shader);

    GLint success;
    glGetShaderiv(shader, GL_COMPILE_STATUS, &success);
    if (!success) {
        char infoLog[512];
        glGetShaderInfoLog(shader, 512, nullptr, infoLog);
        std::cerr << "Shader Compilation Failed: " << infoLog << std::endl;
    }
    return shader;
}

GLuint createShaderProgram(const std::string& shaderFile) {
    const std::string vertShaderPath = "./basic-quad-vert.glsl";
    const std::string fragShaderHeaderPath = "./basic-quad-frag-header.glsl";
    const std::string fragShaderMainPath = "./basic-quad-frag-main.glsl";
    auto vertShaderCode = loadShader(vertShaderPath);
    auto fragShaderCode = loadShader(fragShaderHeaderPath) + "\n" + loadShader(shaderFile) + "\n" + loadShader(fragShaderMainPath);

    GLuint vertexShader = compileShader(vertShaderCode, GL_VERTEX_SHADER);
    GLuint fragmentShader = compileShader(fragShaderCode, GL_FRAGMENT_SHADER);

    GLuint shaderProgram = glCreateProgram();
    glAttachShader(shaderProgram, vertexShader);
    glAttachShader(shaderProgram, fragmentShader);
    glLinkProgram(shaderProgram);

    GLint success;
    glGetProgramiv(shaderProgram, GL_LINK_STATUS, &success);
    if (!success) {
        char infoLog[512];
        glGetProgramInfoLog(shaderProgram, 512, nullptr, infoLog);
        std::cerr << "Shader Program Linking Failed: " << infoLog << std::endl;
    }

    glDeleteShader(vertexShader);
    glDeleteShader(fragmentShader);

    return shaderProgram;
}

bool saveFrameAsImage(const std::string& filename) {
    std::vector<unsigned char> pixels(width * height * 3);  // RGB
    glReadPixels(0, 0, width, height, GL_RGB, GL_UNSIGNED_BYTE, pixels.data());

    return stbi_write_png(filename.c_str(), width, height, 3, pixels.data(), width * 3);
}

bool saveFrameAsImageWithAlpha(const std::string& filename) {
    std::vector<unsigned char> pixels(width * height * 4);  // RGBA
    glReadPixels(0, 0, width, height, GL_RGBA, GL_UNSIGNED_BYTE, pixels.data());

    return stbi_write_png(filename.c_str(), width, height, 4, pixels.data(), width * 4);
}

void parse_arguments(int argc, char* argv[], std::map<std::string, std::string>& params) {
    for (int i = 1; i < argc; i++) {
        std::string arg = argv[i];
        if (arg.substr(0, 2) == "--") {
            std::string key = arg.substr(2);
            if (key == "norender") {
                params[key] = "";
                continue;
            }
            if (i + 1 < argc && argv[i + 1][0] != '-') {
                params[key] = argv[i + 1];
                i++;
            }
            else {
                params[key] = "";
            }
        }
    }
}


int main(int argc, char* argv[]) {
    std::map<std::string, std::string> params;
    parse_arguments(argc, argv, params);

    if (params.count("shader") == 0) {
        std::cout << "ERROR: Must have --shader argument!" << std::endl;
        return -1;
    }

    std::string shaderFile = params["shader"];
    std::string outputPath = params.count("output") ? params["output"] : ".";
    float frameRate = params.count("fps") ? std::stof(params["fps"]) : 30.0f;
    int frameNum = params.count("count") ? std::stoi(params["count"]) : 30;
    int startingFrame = params.count("startframe") ? std::stoi(params["startframe"]) : 0;
    width = params.count("width") ? std::stoi(params["width"]) : 1920;
    height = params.count("height") ? std::stoi(params["height"]) : 1080;
    bool save = params.count("norender") == 0;

    std::cout << "Shader file: " << shaderFile << std::endl;
    std::cout << "Output path: " << outputPath << std::endl;
    std::cout << "Framerate: " << frameRate << std::endl;
    std::cout << "Frame count: " << frameNum << std::endl;
    std::cout << "Starting frame: " << startingFrame << std::endl;
    std::cout << "Width: " << width << std::endl;
    std::cout << "Height: " << height << std::endl;
    std::cout << "Rendering: " << (save ? "Yes" : "No") << std::endl;

    if (!glfwInit()) {
        std::cerr << "ERROR: Failed to initialize GLFW" << std::endl;
        return -1;
    }

    glfwWindowHint(GLFW_CONTEXT_VERSION_MAJOR, 4);
    glfwWindowHint(GLFW_CONTEXT_VERSION_MINOR, 5);
    GLFWwindow* window = glfwCreateWindow(width, height, "ShaderToy Renderer", nullptr, nullptr);
    if (!window) {
        std::cerr << "ERROR: Failed to create GLFW window" << std::endl;
        glfwTerminate();
        return -1;
    }
    glfwMakeContextCurrent(window);

    glewExperimental = GL_TRUE;
    if (glewInit() != GLEW_OK) {
        std::cerr << "ERROR: Failed to initialize GLEW" << std::endl;
        glfwTerminate();
        return -1;
    }

    GLuint shaderProgram = createShaderProgram(shaderFile);

    GLint resolutionLoc = glGetUniformLocation(shaderProgram, "iResolution");
    GLint timeLoc = glGetUniformLocation(shaderProgram, "iTime");
    GLint frameLoc = glGetUniformLocation(shaderProgram, "iFrame");
    GLint framerateLoc = glGetUniformLocation(shaderProgram, "iFramerate");

    float resolution[3] = { static_cast<float>(width), static_cast<float>(height), 0 };

    float vertices[] = {
        -1.0f, -1.0f,   0.0f, 0.0f,  // aPos, aTexcoord
        1.0f, -1.0f,    1.0f, 0.0f,
        -1.0f,  1.0f,   0.0f, 1.0f,

        -1.0f,  1.0f,   0.0f, 1.0f,
        1.0f, -1.0f,    1.0f, 0.0f,
        1.0f,  1.0f,    1.0f, 1.0f
    };

    glViewport(0, 0, width, height);

    GLuint VBO, VAO;
    glGenBuffers(1, &VBO);
    glGenVertexArrays(1, &VAO);

    glBindVertexArray(VAO);

    glBindBuffer(GL_ARRAY_BUFFER, VBO);
    glBufferData(GL_ARRAY_BUFFER, sizeof(vertices), vertices, GL_STATIC_DRAW);

    // aPos
    glVertexAttribPointer(0, 2, GL_FLOAT, GL_FALSE, 4 * sizeof(float), (void*)0);
    glEnableVertexAttribArray(0);

    // aTexcoord
    glVertexAttribPointer(1, 2, GL_FLOAT, GL_FALSE, 4 * sizeof(float), (void*)(2 * sizeof(float)));
    glEnableVertexAttribArray(1);

    glBindBuffer(GL_ARRAY_BUFFER, 0);
    glBindVertexArray(0);

    GLuint framebuffer, texture;
    glGenFramebuffers(1, &framebuffer);
    glGenTextures(1, &texture);

    glBindTexture(GL_TEXTURE_2D, texture);
    glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA, width, height, 0, GL_RGBA, GL_UNSIGNED_BYTE, NULL);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);

    glBindFramebuffer(GL_FRAMEBUFFER, framebuffer);
    glFramebufferTexture2D(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0, GL_TEXTURE_2D, texture, 0);

    if (glCheckFramebufferStatus(GL_FRAMEBUFFER) != GL_FRAMEBUFFER_COMPLETE) {
        std::cerr << "ERROR: Framebuffer not complete!" << std::endl;
        return -1;
    }
    glBindFramebuffer(GL_FRAMEBUFFER, 0);

    int frame = startingFrame;
    while (!glfwWindowShouldClose(window) && (frame < startingFrame + frameNum || !save)) {
        glUseProgram(shaderProgram);

        glUniform3fv(resolutionLoc, 1, resolution);
        glUniform1f(timeLoc, frame / frameRate);
        glUniform1f(framerateLoc, frameRate);
        glUniform1i(frameLoc, frame);

        glBindVertexArray(VAO);

        if (save) {
            glBindFramebuffer(GL_FRAMEBUFFER, framebuffer);
            glClear(GL_COLOR_BUFFER_BIT);
            glDrawArrays(GL_TRIANGLES, 0, 6);
            std::ostringstream oss;
            oss << std::setw(4) << std::setfill('0') << frame;
            std::string filename = outputPath + "/frame_" + oss.str() + ".png";

            std::cout << "Writing Frame " << frame << " to file " << filename << "..." << std::endl;

            bool res = saveFrameAsImageWithAlpha(filename);
            if (!res) {
                std::cout << "ERROR: Image writing failed!" << std::endl;
                return -1;
            }
        }

        glBindFramebuffer(GL_FRAMEBUFFER, 0);
        glDrawArrays(GL_TRIANGLES, 0, 6);
        frame++;

        glfwSwapBuffers(window);
        glfwPollEvents();
    }

    glDeleteVertexArrays(1, &VAO);
    glDeleteBuffers(1, &VBO);
    glDeleteProgram(shaderProgram);

    glfwTerminate();
    return 0;
}
