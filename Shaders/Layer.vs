#version 330 core

layout(location = 0) in vec3 _Position;
layout(location = 1) in vec2 _UV;

out vec2 WindowUV;

uniform mat4  MVP;
uniform float WidthPercentageCoverage;
uniform float HeightPercentageCoverage;

/*
	Each background layer displays a 
	window to the player, based on where the
	player is on the playing layer.
	
	If the player has 1 on the WidthPercentageCoverage
	then we don't want the background layers to displays
	stuff around that WidthPercentageCoverage.
	Rather, when the player has 1 WidthPercentageCoverage
	or 0 WidthPercentageCoverage, we want to be able to see
	the edges of all background layers.
	
	Hence the WidthCorrection and HeightCorrection,
	which looks like are non linear, but idk yet.
	Might be nice..
*/

void main() {
    gl_Position = MVP * vec4(_Position, 1.0);

	float WidthCorrection = abs(_UV.x) + WidthPercentageCoverage * (1.0 - WidthPercentageCoverage);
	WidthCorrection = mix(WidthCorrection, -WidthCorrection, WidthPercentageCoverage);
	
	float HeightCorrection = abs(_UV.y) + HeightPercentageCoverage * (1.0 - HeightPercentageCoverage);
	HeightCorrection = mix(HeightCorrection, -HeightCorrection, HeightPercentageCoverage);
	
	WindowUV = _UV + vec2(WidthCorrection, HeightCorrection);
}
