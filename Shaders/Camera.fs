#version 330 core

in vec2 UV;

uniform vec2 Color;

out vec4 FragColor;
const float T = 0.075;

void main() {
	float distance = 1.0 - length(UV - 0.5);
		
	if (!(distance > 0.5 && distance < 0.5+T))
		discard;
	
	FragColor = vec4(Color.x, Color.y, 0, 1);
}