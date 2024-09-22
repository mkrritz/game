#version 330 core

#define BASE 0
#define LENGTH 1
#define TIMER 2
#define DURATION 3
#define SCALE 0
#define SPEED 1
#define VELOCITY 2
#define ANIMATIONS 8

layout(location = 0) in vec3 _Color;
layout(location = 1) in mat4 _Instance;
layout(location = 5) in vec4 _Info;
layout(location = 6) in vec4 _Properties;
layout(location = 7) in vec3 _CurrentPosition;
layout(location = 8) in vec3 _TravelingPosition;
layout(location = 9) in vec3 _ControlPoint;

out mat4 Instance;
out vec4 Info;
out vec4 Properties;
out vec3 CurrentPosition;
out vec3 TravelingPosition;
out vec3 ControlPoint;

uniform vec2 Map[ANIMATIONS];
uniform float DeltaTime;
uniform uint InstanceCount;
uniform vec3 Direction;
uniform vec4 Probabilities;

const float StateTransitionMatrix[64] = float[64](
/*                    TAKEOFF   |  FLYING  |  LANDING  |  IDLE  |  CLOSE_WINGS  |  IDLE_CLOSE_WINGS  |  IDLE_FLAP_WINGS  |  OPEN_WINGS  */

/*          TAKEOFF */    0     ,   0.95   ,   0.05    ,   0    ,       0       ,         0         ,         0         ,      0,

/*           FLYING */    0     ,   0.9    ,   0.1     ,   0    ,       0       ,         0         ,         0         ,      0,

/*          LANDING */    0     ,    0     ,    0      ,  0.7   ,      0.3      ,         0         ,         0         ,      0,

/*             IDLE */   0.1    ,    0     ,    0      ,  0.7   ,      0.2      ,         0         ,         0         ,      0,

/*      CLOSE_WINGS */    0     ,    0     ,    0      ,   0    ,       0       ,        0.85       ,        0.1         ,    0.05,

/* IDLE_CLOSE_WINGS */    0     ,    0     ,    0      ,   0    ,       0       ,        0.9        ,        0.05       ,     0.05,

/*  IDLE_FLAP_WINGS */    0     ,    0     ,    0      ,   0    ,       0       ,        0.6        ,        0.1        ,     0.3,

/*       OPEN_WINGS */   0.4    ,    0     ,    0      ,  0.5   ,      0.1      ,         0         ,         0        ,      0

);

int NewAnimation(float PreviousAnimation, inout vec3 TargetPosition, inout vec3 ControlPosition, inout float PerInstanceDuration) {
	int PreviousAnimationIndex;
	if (PreviousAnimation == Map[0][BASE]) {        // TAKEOFF
		PreviousAnimationIndex = 0;
	} else if (PreviousAnimation == Map[1][BASE]) { // FLYING
		PreviousAnimationIndex = 1;
	} else if (PreviousAnimation == Map[2][BASE]) { // LANDING
		PreviousAnimationIndex = 2;
	} else if (PreviousAnimation == Map[3][BASE]) { // IDLE_OPEN_WINGS
		PreviousAnimationIndex = 3;
	} else if (PreviousAnimation == Map[4][BASE]) { // CLOSE_WINGS
		PreviousAnimationIndex = 4;
	} else if (PreviousAnimation == Map[5][BASE]) { // IDLE_CLOSE_WINGS
		PreviousAnimationIndex = 5;
	} else if (PreviousAnimation == Map[6][BASE]) { // IDLE_FLAP_WINGS
		PreviousAnimationIndex = 6;
	} else if (PreviousAnimation == Map[7][BASE]) { // OPEN_WINGS
		PreviousAnimationIndex = 7;
	}
	
	float StateTransitionProbabilities[ANIMATIONS];
	StateTransitionProbabilities[0] = StateTransitionMatrix[PreviousAnimationIndex * ANIMATIONS + 0];
	for (int i = 1; i < ANIMATIONS; i++)
		StateTransitionProbabilities[i] = StateTransitionProbabilities[i - 1] + StateTransitionMatrix[PreviousAnimationIndex * ANIMATIONS + i];	
	int NewAnimationIndex = 0;
	for (int i = 0; i < ANIMATIONS; i++)
		if (Probabilities.x < StateTransitionProbabilities[i]){
			NewAnimationIndex = i;
			break;
		}
	
	Properties[SPEED] = 1.0;
	Properties[VELOCITY] = 0.0;
	
	if (NewAnimationIndex == 0) {        // TAKEOFF
		
		Properties[VELOCITY] = 10.0;
		TargetPosition += Properties[VELOCITY] * vec3(0, 1, 0);
		ControlPosition = (TargetPosition + CurrentPosition) / 2.0;
		PerInstanceDuration = distance(CurrentPosition, TargetPosition) / Properties[VELOCITY];
		
	} else if (NewAnimationIndex == 1) { // FLYING
	
		Properties[SPEED] = 10.0;
		Properties[VELOCITY] = 40.0;
		TargetPosition += Properties[VELOCITY] * Direction;
		ControlPosition = (TargetPosition + CurrentPosition) / 2.0 + 20.0 * Direction;
		PerInstanceDuration = distance(CurrentPosition, TargetPosition) / Properties[VELOCITY];
		
	} else if (NewAnimationIndex == 2) { // LANDING
	
		PerInstanceDuration = 0.1;
		TargetPosition.y = 0.0;
		
	} else if (NewAnimationIndex == 3) { // IDLE_OPEN_WINGS
	
		PerInstanceDuration = 1.0;
		
	} else if (NewAnimationIndex == 4) { // CLOSE_WINGS
	
		PerInstanceDuration = 1.0;
		
	} else if (NewAnimationIndex == 5) { // IDLE_CLOSE_WINGS
	
		PerInstanceDuration = 1.0;
		
	} else if (NewAnimationIndex == 6) { // IDLE_FLAP_WINGS
	
		PerInstanceDuration = 1.0;
		
	} else if (NewAnimationIndex == 7) { // OPEN_WINGS
	
		PerInstanceDuration = 1.0;
		
	}	
	
	return NewAnimationIndex;
}

void main() {	
	mat4 T = mat4(1.0);
	//T[3] = vec4((_CurrentPosition * (1.0 - _Info[TIMER] / _Info[DURATION])) + (_TravelingPosition * _Info[TIMER] / _Info[DURATION]), 1.0);
	//T[3] = vec4(mix(_CurrentPosition, _TravelingPosition, _Info[TIMER] / _Info[DURATION]), 1.0);
	
	float Timer = _Info[TIMER] / _Info[DURATION];

	vec3 position = (1.0 - Timer) * (1.0 - Timer) * _CurrentPosition + 2.0 * (1.0 - Timer) * Timer * _ControlPoint + Timer * Timer * _TravelingPosition;
	T[3] = vec4(position, 1.0);
	//T[3] = vec4((_CurrentPosition * (1.0 - _Info[TIMER] / _Info[DURATION])) + (_TravelingPosition * _Info[TIMER] / _Info[DURATION]), 1.0);
	
	mat4 S = mat4(1.0);
	S[0][0] = _Properties[SCALE] * 50.0;
	S[1][1] = _Properties[SCALE] * 50.0;
	S[2][2] = _Properties[SCALE] * 50.0;
	
	Instance = T * S; // Rotations too please
	Info = _Info + vec4(0, 0, DeltaTime, 0);
	Properties = _Properties;
	CurrentPosition = _CurrentPosition;
	TravelingPosition = _TravelingPosition;
	ControlPoint = _ControlPoint;
	
	if (Info[TIMER] > Info[DURATION]) { // Animation expired for current instance. Instance is so close at reaching TravelingPosition.
		float PerInstanceDuration = 1.0;
		
		CurrentPosition = _TravelingPosition;
		vec3 TargetPosition = CurrentPosition;
		vec3 ControlPosition = CurrentPosition;
		int NewAnimationIndex = NewAnimation(_Info[BASE], TargetPosition, ControlPosition, PerInstanceDuration);
		TravelingPosition = TargetPosition;
		ControlPoint = ControlPosition;
		
		// Is this bad? yes. get rid of this shit. But also how to have randoms? Maybe the way PerInstanceDuration is calculated will just fix this in the end
		PerInstanceDuration += float(gl_InstanceID) / InstanceCount;		
		Info = vec4(Map[NewAnimationIndex][BASE], Map[NewAnimationIndex][LENGTH], 0.0, PerInstanceDuration);
	}
}

/*
	@_Color/Color:
		Per vertex attributes for whatever comes next.
		Right now just a color, might become material properties later.
		Or physics properties for accelerations and other behaviour.
	@_Instance/Instance:
		Per instance full transform.
	@_Info/Info:
		Per instance animation info.
			BASE:
				The row in pixels, where the current animation starts.
			LENGTH:
				The length in pixels, indicating how many frames this animation has.
			TIMER:
				In the range [ 0, +inf ]
				Drives the animation!
			DURATION:
				In the range [ 0, +inf ]
				How much time it will take for the animation to complete once.
	@_Properties/Properties:
		Per instance physical state.
			SCALE:
				The scale of each instance. So as to not have every model be the same size.
				Also, might be used to shrink and enlarge stuff, for reasons. But this will require
				updating the Properties buffer every frame and also based on the animation that
				implies shrinkage. 
			SPEED:
				How many times the current animation will play over DURATION seconds.
			VELOCITY:
				How many units to travel towards the specified direction.
				Make this unique per instance so as for VELOCITY to become a source of randomness.
				That way the PerInstanceDuration would be different for everybody.
			_:
				_
	@_CurrentPosition/CurrentPosition:
		Per instance starting position in the world.
	@_TravelingPosition/TravelingPosition:
		Per instance target position in the world, to be reached in PerInstanceDuration time.
	@_ControlPoint/ControlPoint:
		Per instance control position in the world, to travel curvely
		
///////////////////////////////////////////////////////////////////////////////////////////////////

	@Map[ANIMATIONS]:
		The base and length of each animation. In the same order as that of the image.
		Used to sample from and take action, when the timer for any instance expires.
			( ANIMATIONS can be made known from the CPU. But we know it already.
			  I guess do that when there are many groups of animals.
			  Something like: uniform vec2 Map[32] and an ANIMATIONS_COUNT uniform. )
	@DeltaTime:
		The one and only universal way that time is flowing for every being.
	@InstanceCount:
		In the range [ 0, +inf ]
		The number of instances that this shader will operate on.
		This uniform is really only used to add some variance to the Duration,
		to compensate for the fact that many instances can simultaneously pass the check.
	@Direction:
		idk. here for the lols until i have controlled movement.
	@Probabilities:
		In the range [ 0, 1 ]
		Four random numbers for whatever comes up.
		So far only .x is used for transitioning states. 
			(TODO: How to have an explicit sequence of animations over durations?)
///////////////////////////////////////////////////////////////////////////////////////////////////
	
	@T:
		The position of the instance in the world.
		When the state of the instance is *idle*, then we are just simulating the animation 
		with the PerInstanceDuration and probably always Properties[SPEED] = 1.
		The animation plays once in that time and also
		we will be having that _CurrentPosition == _TravelingPosition.
	@R:
		The rotations somehow sometime.
	@S:
		The scale of each instance for variations.
	@PerInstanceVariance
		In the range [ 0, 1 ]
		Each instance has a unique value in that range.
	@PerInstanceDuration:
		The time it takes to go from CurrentPosition to TravelingPosition (s=m/u).
		Also, the time it takes, in seconds, to complete the chosen animation once.
	@PreviousAnimation:
		The previous animation is identified by the value of its BASE,
		which is the starting pixel of that animation.
	@PreviousAnimationIndex:
		The animation that just ended.
		Used to reason about the next animation that should take place.
		For now that's done at random based on the StateTransitionMatrix.
	@NewAnimationIndex:
		The new animation that will run for Properties[SPEED] times, over PerInstanceDuration seconds.
	@TargetPosition
		Starts of with a value equal to the CurrentPosition, that means the instance will not be moving.
		That instance might start moving if its state implies that (walk, run, jump, fly, w/e)
		otherwise it will be performing some IDLE animation (preferably with Properties[SPEED] = 1) over PerInstanceDuration seconds.
	@StateTransitionProbabilities:
		The cumulative sum of the previous animations' StateTransitionMatrix in order to figure
		out what the next state should be, based on a random number (Probabilities.x).
		Can this be done to be based on things like:
			At night the state is very likely IDLE_CLOSE_WINGS.
			In the morning not so much.
			Also, what about weather?
			What about other surrounding threats?
		
*/