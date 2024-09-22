#version 330 core

#define PARTICLE_TIME 0
#define PARTICLE_LIFE 1

layout(location = 0) in vec3 _Position;   // variable
layout(location = 1) in vec2 _Info;       // variable
layout(location = 2) in vec3 _Start;	  // constant

uniform float SimulationStep;

out vec3 Position;
out vec2 Info;

void main() {
	vec3 End = _Start + vec3(0, -300, 0);
	float Progress = _Info[PARTICLE_TIME] / _Info[PARTICLE_LIFE];
	vec3 P = _Start * (1.0 - Progress) + End * Progress;


	Position = P;
	Info = _Info + vec2(SimulationStep, 0);
	
	if (_Info[PARTICLE_TIME] > _Info[PARTICLE_LIFE]) {
		Info = vec2(_Info[PARTICLE_TIME] - _Info[PARTICLE_LIFE], _Info[PARTICLE_LIFE]);
	}
}
