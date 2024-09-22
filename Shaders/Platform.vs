#version 330 core

layout(location = 0) in vec3 _Position;

uniform mat4 MVP; // VP really

void main() {
    gl_Position = MVP * vec4(_Position, 1.0);
}
