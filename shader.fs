#version 330

// built-in values:
in vec2 fragTexCoord;       // uv
in vec4 fragColor;          // vertex color

out vec4 finalColor;

uniform sampler2D texture0;
uniform vec4 colDiffuse;

// custom uniforms:
uniform int texMode;
uniform int texX;
uniform int texY;
uniform int texW;
uniform int texH;

uniform int fogMode;
uniform float fogStart;
uniform float fogEnd;
uniform vec4 fogColor;

void main()
{
	// wrap/clamp coords into range
	vec2 wrappedCoord;

	if (texMode == 0) {
		wrappedCoord = mod(fragTexCoord, vec2(1.0f, 1.0f));
	}
	else {
		wrappedCoord = clamp(fragTexCoord, vec2(0.0f, 0.0f), vec2(0.99f, 0.99f));
	}
	
	// create vectors
	vec2 tMin = vec2(float(texX), float(texY));
	vec2 tMax = vec2(float(texX + texW), float((texY) + texH));
	vec2 tSize = vec2(1024.0f, 1024.0f);

	// get mapped uv coords
	vec2 mappedCoord = mix(tMin, tMax, wrappedCoord) / tSize;
	
	// sample color from texture
    vec4 rawColor = texture(texture0, mappedCoord) * fragColor;

	// calculate fog
	float dist = (gl_FragCoord.z / gl_FragCoord.w);
	float fogFactor;
	if (fogStart == fogEnd) {
		fogFactor = 1.0;
	}
	else {
		fogFactor = fogEnd - fogStart;
	}
	fogFactor = clamp((fogEnd - dist) / fogFactor, 0.0f, 1.0f);

	if (fogMode == 1) {
		finalColor = mix(fogColor, rawColor, fogFactor);
	}
	else {
		finalColor = rawColor;
	}
}
