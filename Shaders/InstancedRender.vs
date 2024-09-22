#version 330 core

#define BASE 0
#define LENGTH 1
#define TIMER 2
#define DURATION 3
#define SCALE 0
#define SPEED 1

layout(location = 0) in vec3 _Color;
layout(location = 1) in mat4 _Instance;
layout(location = 5) in vec4 _Info;
layout(location = 6) in vec4 _Properties;
layout(location = 7) in vec3 _CurrentPosition;    // Useless here, how to not have them
layout(location = 8) in vec3 _TravelingPosition;  // Useless here, how to not have them
layout(location = 9) in vec3 _ControlPoint;       // Useless here, how to not have them

out vec3 Color;
//flat out vec3 Color;

uniform mat4 VP;
uniform sampler2D Sampler;
uniform vec2 Size;
uniform vec3 Mins;
uniform vec3 Maxs;
uniform vec3 Ranges;

void main() {
	float AnimationSpeed = _Properties[SPEED];
	
	float Vertex = float(gl_VertexID) / Size.x;
	float Frame =  fract(AnimationSpeed * _Info[TIMER] / _Info[DURATION]) * _Info[LENGTH];

	float PreviousFrame = (_Info[BASE] + floor(Frame)) / Size.y;
	float NextFrame     = (_Info[BASE] + ceil(Frame))  / Size.y;
	float Progress      = Frame - floor(Frame);

	vec3 NormalizedPosition = mix(
                                  texture(Sampler, vec2(Vertex, PreviousFrame)).xyz, 
                                  texture(Sampler, vec2(Vertex, NextFrame)).xyz,
                                  Progress
                                 );

	vec3 LocalPosition = NormalizedPosition * Ranges + Mins;
	vec4 WorldPosition = VP * _Instance * vec4(LocalPosition, 1.0);
	gl_Position = WorldPosition;
	Color = _Color;
}

/*
	0     1     2     3     4     5     6     7     8
	F     F     F     F     F     F     F     F     F
	|-----|-----|-----|-----|-----|-----|-----|-----|...
	   P     P     P     P     P     P     P     P
	  0-1   0-1   0-1   0-1   0-1   0-1   0-1   0-1
	  
	@_Color/Color:
		Per vertex constant attributes for whatever comes next
		Right now just a color, might become material properties later.
	@_Instance/Instance:
		Per instance full transform
	@_Info/Info:
		Per instance animation state
	@_Properties/Properties:
		Only SPEED is used here to allow for a single animation
		to loop multiple times in DURATION seconds.

///////////////////////////////////////////////////////////////////////////////////////////////////

	@Sampler:
		A nearest sampler because we want no interpolations along the Width axis
		But we do want interpolation along the Height axis. Which is what this shader is doing.
	@Size:
		The Width and Height of the image that the Sampler is sampling from.
		The Width is the number of vertices that the model has.
		The Height is a collection of animations, where we choose which one
		to run, based on each instance state. Each pixel is a NormalizedPosition.
	@(Mins, Maxs, Ranges):
		Used to transform the model vertices from RGB space to local space.
		The resolution of these 3 variables is in meters.

///////////////////////////////////////////////////////////////////////////////////////////////////

	@AnimationSpeed:
		How many times the current animation will loop in DURATION seconds.
		This is here to allow the same animation to play multiple time, regardless of 
		the distance between CurrentPosition and TravelingPosition and the time
		it will take to cover that distance.
			E.g.
				A simple walk animation will be played once, in one second, to cover one meter.
				The same animation must be played five times to walk five meters in five seconds.
				So AnimationSpeed in this case is 5, otherwise the instance would indeed travel
				five meters in five seconds, but the animation would only be played once.
				Is this the way? How to speed everything up and slow everything slow uniformly?
				Apparently by changing the dt step 
				 (    which we should then rename to SimulationTimeStep
				           and not have it be const or something          )
				All these are not really a problem if we take frequent and small steps, which we 
				most likely will be taking, because what else is there? Except for controlled behaviour,
				but that's for layer NPCs, not environment NPCs.
				I mean, ideally we are taking action every planck,
				but every second doesn't sound that bad either. Also, reaction times.
	@Vertex:
		In the range [ 0, 1 ]
		Used to sample NormalizedPosition
			( The order vertices are stored in the VBO (and then as indexed by the indices)
			  apparently agrees with the order vertices are stored in the animation image (SHUFIM.py) )
	@Frame:
		In the range [ 0, _Info[LENGTH] ]
		Maybe needs an ε to avoid leaking to next completely irrelevant animation
		Or double the last frame of each animation
			( This is not a problem if each animation starts and ends at the same pose )
	@PreviousFrame:
		In the range [ 0, 1 ]
		Used to sample NormalizedPosition
	@NextFrame:
		In the range [ 0, 1 ]
		Used to sample NormalizedPosition
	@Progress:
		In the range [ 0, 1 ]
		Interpolates between previous pixel and next pixel
	@NormalizedPosition:
		In the range [ 0, 1 ]
		The local position of each vertex in RGB space
	@LocalPosition:
		In the range [ -inf, +inf ]
		The local position of each vertex
	@WorldPosition:
		In the range [ -inf, +inf ]
		The world position of each vertex
*/
