#version 330 core

layout(location = 0) in vec3 _Position;
layout(location = 1) in vec2 _UV;

uniform mat4 MVP;

out vec2 UV;

void main()
{
	gl_Position = MVP * vec4(_Position, 1.0);
	UV = _UV;
}
