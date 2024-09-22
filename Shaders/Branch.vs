#version 330 core

layout(location = 0) in vec4 _XYZR;

void main()
{
    gl_Position = _XYZR;
}
