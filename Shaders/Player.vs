#version 330 core

#define BASE 0
#define LENGTH 1

layout(location = 0) in vec3 _Color;

out vec3 Color;

uniform mat4 MVP;
uniform vec3 Mins;
uniform vec3 Maxs;
uniform vec3 Ranges;
uniform vec2 BaseLength;
uniform vec2 Size;
uniform float Timer;
uniform float Duration;
uniform sampler2D Sampler;

void main() {
	float Vertex = float(gl_VertexID) / Size.x;
	float Frame =  fract(Timer / Duration) * BaseLength[LENGTH];
	
	float PreviousFrame = (BaseLength[BASE] + floor(Frame)) / Size.y;
	float NextFrame     = (BaseLength[BASE] + ceil(Frame))  / Size.y;
	float Progress      = Frame - floor(Frame);

	vec3 NormalizedPosition = mix(
                                  texture(Sampler, vec2(Vertex, PreviousFrame)).xyz, 
                                  texture(Sampler, vec2(Vertex, NextFrame)).xyz,
                                  Progress
                                 );

	vec3 LocalPosition = NormalizedPosition * Ranges + Mins;
	vec4 WorldPosition = MVP * vec4(LocalPosition, 1.0);
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
		Per vertex attributes for whatever comes next
		Right now just a color, might become material properties later.
		
///////////////////////////////////////////////////////////////////////////////////////////////////

	@BaseLength:
		Base: The row in pixels, where the current animation starts
		Length: The length in pixels, indicating how many frames this animation has
	@Timer:
		In the range [ 0, +inf ]
		Drives the animation!
	@Duration:
		In the range [ 0, +inf ]
		How much time it will take for the animation to complete once
	@Sampler:
		A nearest sampler because we want no interpolations along the Width axis
		But we do want interpolation along the Height axis. And this is what this shader is doing.
	@Size:
		The Width and Height of the image that the Sampler is sampling from.
		The Width is the number of vertices that the model has.
		The Height is a collection of animations, where we choose which one
		to run, based on the model state. Each pixel is a NormalizedPosition.
	@(Mins, Maxs, Ranges):
		Used to transform the model vertices from RGB space to local space.
		The resolution of these 3 variables is in meters.

///////////////////////////////////////////////////////////////////////////////////////////////////

	@Vertex:
		In the range [ 0, 1 ]
		Used to sample NormalizedPosition
			( The order vertices are stored in the VBO (and then as indexed by the indices)
			  apparently matches with the order vertices are stored in the animation image (SHUFIM.py) )
	@Frame:
		In the range [ 0, BaseLength[LENGTH] ]
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
