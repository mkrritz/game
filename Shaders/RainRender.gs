#version 330 core

layout (points) in;
layout (triangle_strip, max_vertices = 4) out;

uniform mat4 MVP;

out vec2 UV;

const vec4 VertexOffet[4] = vec4[](vec4(-1, -1, 0.0, 0.0),
                                   vec4( 1, -1, 0.0, 0.0),
                                   vec4(-1,  1, 0.0, 0.0),
                                   vec4( 1,  1, 0.0, 0.0));
							  
const vec2 VertexUV[4]    = vec2[](vec2(0.0, 0.0),
                                   vec2(1.0, 0.0),
                                   vec2(0.0, 1.0),
                                   vec2(1.0, 1.0));							   
void main() {
    vec4 Droplet = gl_in[0].gl_Position;
	
	gl_Position = MVP * (Droplet + VertexOffet[0]);
	UV = VertexUV[0];
	EmitVertex();
	
	gl_Position = MVP * (Droplet + VertexOffet[1]);
	UV = VertexUV[1];
	EmitVertex();
	
	gl_Position = MVP * (Droplet + VertexOffet[2]);
	UV = VertexUV[2];
	EmitVertex();
	
	gl_Position = MVP * (Droplet + VertexOffet[3]);
	UV = VertexUV[3];
	EmitVertex();
	
    EndPrimitive();
}
