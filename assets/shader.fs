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

vec4 getTexColor(vec2 coord) {
	// create vectors
	vec2 tMin = vec2(float(texX), float(texY));
	vec2 tMax = vec2(float(texX + texW), float((texY) + texH));
	vec2 tSize = vec2(1024.0f, 1024.0f);

	// get mapped uv coords
	vec2 mappedCoord = mix(tMin, tMax, coord) / tSize;
	
	// sample color from texture
    vec4 rawColor = texture(texture0, mappedCoord) * fragColor;

	return rawColor;
}

void main()
{
	vec4 rawColor;

	if (texMode == 0) {
		rawColor = getTexColor(mod(fragTexCoord, vec2(1.0f, 1.0f)));
	}
	else if (texMode == 1) {
		rawColor = getTexColor(clamp(fragTexCoord, vec2(0.0f, 0.0f), vec2(0.99f, 0.99f)));
	}
	else {
		rawColor = vec4(1.0f, 1.0f, 1.0f, 1.0f) * fragColor;
	}

	if (fogMode == 1) {
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

		finalColor = mix(fogColor, rawColor, fogFactor);
	}
	else {
		finalColor = rawColor;
	}
}
