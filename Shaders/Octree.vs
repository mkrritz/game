#version 330 core

layout(location = 0) in vec3 _Position;

uniform mat4 MVP;

out vec3 Position;

void main()
{
	Position = _Position;
	gl_Position = MVP * vec4(_Position.x, _Position.y, _Position.z, 1.0);
}
