#version 330 core

layout(location = 0) in vec3 _Position;

uniform mat4 MVP;

out vec3 Position;

void main()
{
	/*
		Force cubemap to be the farthest, which then requires glDepthFunc(GL_LEQUAL), to be visible
	*/
	gl_Position = (MVP * vec4(_Position, 1.0)).xyzw;
	Position = _Position;
}
