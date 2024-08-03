shader_type spatial;

global uniform sampler2D height_map4;
global uniform sampler2D normal_map4;
global uniform float amplitude;

varying vec2 texture_position;

void vertex() {
	// Called for every vertex the material is visible on.
	textureSize(height_map4, 0);
	texture_position = VERTEX.xz;
	VERTEX.y = texture(height_map4, texture_position).r * amplitude;
	
}

void fragment() {
	// Called for every pixel the material is visible on.
	
	NORMAL_MAP = texture(normal_map4, texture_position).rgb;
}

//void light() {
	// Called for every pixel for every light affecting the material.
	// Uncomment to replace the default light processing function with this one.
//}
