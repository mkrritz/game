#version 330 core

layout(location = 0) in vec3 _Position;
layout(location = 1) in vec2 _Info;   // useless here, what's the setup?
layout(location = 2) in vec3 _Start;  // useless here, what's the setup?

void main()
{
    gl_Position = vec4(_Position, 1.0);
}
