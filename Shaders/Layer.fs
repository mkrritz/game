#version 330 core

in vec2 WindowUV;
out vec4 FragColor;

uniform sampler2D Sampler;
uniform float WidthPercentageCoverage;
uniform float HeightPercentageCoverage;

void main()
{
	vec2 BackgroundSamplingPoint = vec2(WidthPercentageCoverage, HeightPercentageCoverage);
	FragColor = texture(Sampler, BackgroundSamplingPoint + WindowUV);
}