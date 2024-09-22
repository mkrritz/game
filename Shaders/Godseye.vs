#version 330 core

layout(location = 0) in vec3 _Position;

uniform  mat4 View;
uniform  mat4 ViewGodseye;
uniform  mat4 ProjectionGodseye;
uniform  vec3 CameraPosition;
uniform float Aspect;
uniform float FOV;
uniform float NearPlane;
uniform float FarPlane;

vec3 Right, Up, Forward;

void main() {
	Right   = vec3( View[0][0],  View[1][0],  View[2][0]);
	Up      = vec3( View[0][1],  View[1][1],  View[2][1]);
	Forward = vec3(-View[0][2], -View[1][2], -View[2][2]);
	
	float NearHalfHeight = NearPlane * tan(radians(FOV) / 2.0);
    float NearHalfWidth  = NearHalfHeight * Aspect;
	float FarHalfHeight  = FarPlane * tan(radians(FOV) / 2.0);
    float FarHalfWidth   = FarHalfHeight * Aspect;
    vec3 NearCenter = CameraPosition + Forward * NearPlane;
    vec3 FarCenter = CameraPosition + Forward * FarPlane;

    vec3 WorldPosition = mix(
						NearCenter + Right * (_Position.x * NearHalfWidth) + Up * (_Position.y * NearHalfHeight),
						FarCenter  + Right * (_Position.x * FarHalfWidth)  + Up * (_Position.y * FarHalfHeight),
						_Position.z
					);
					
    gl_Position = ProjectionGodseye * ViewGodseye * vec4(WorldPosition, 1.0);
}
