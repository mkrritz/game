#version 330 core

in vec2 UV;

out vec4 FragColor;

void main()
{
	float distance = 1.0 - length(UV - 0.5);
		
	if (!(distance > 0.5))
		discard;
	
	FragColor = vec4(0, 1, 1, 1);
}