#version 330 core

in vec3 Position;

uniform samplerCube Sampler;

out vec4 FragColor;

void main() {
    FragColor = texture(Sampler, Position);
    //FragColor = vec4(Position, 1);
}