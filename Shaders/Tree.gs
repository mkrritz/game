#version 330 core

layout (points) in;
layout (triangle_strip, max_vertices = 4) out;

uniform mat4 MVP; // VP really

out vec2 UV;

void main() {
    vec4 Tree = vec4(gl_in[0].gl_Position.xyz, 1.0);	
	float Radius = gl_in[0].gl_Position.w;
	
	vec4 BL = vec4(-Radius, 0, -Radius, 0);
	gl_Position = MVP * (Tree + BL);
	UV = vec2(0, 0);
	EmitVertex();
	
	vec4 TL = vec4(-Radius, 0, Radius, 0);
	gl_Position = MVP * (Tree + TL);
	UV = vec2(1, 0);
	EmitVertex();
	
	vec4 BR = vec4(Radius, 0, -Radius, 0);
	gl_Position = MVP * (Tree + BR);
	UV = vec2(0, 1);
	EmitVertex();
	
	vec4 TR = vec4(Radius, 0, Radius, 0);
	gl_Position = MVP * (Tree + TR);
	UV = vec2(1, 1);
	EmitVertex();
	
    EndPrimitive();
}
