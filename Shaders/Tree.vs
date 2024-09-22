#version 330 core

layout(location = 0) in vec4 _XYZR;

uniform float CameraHeight;

void main()
{
    gl_Position = _XYZR + vec4(0, CameraHeight, 0, 0);
}
