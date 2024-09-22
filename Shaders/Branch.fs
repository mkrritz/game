#version 330 core

in vec2 UV;

out vec4 FragColor;

const float T = 0.075; // The thickness of a circle, a value in the [0.0, 0.5] range

void main()
{
	float distance = 1.0 - length(UV - 0.5);
	float circle = step(0.5, distance) * (1.0 - step(0.5+T, distance));
		
	if (!(distance > 0.5 && distance < 0.5+T))
		discard;
	
	FragColor = vec4(1,0,1,1);
}