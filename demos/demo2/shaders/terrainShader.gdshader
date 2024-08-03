shader_type spatial;
uniform sampler2D heightmap_data;
uniform sampler2D normalmap_data;

global uniform float amplitude;

varying vec2 texture_position;

void vertex() {
	// Called for every vertex the material is visible on.
	vec3 world_vertex = VERTEX + MODEL_MATRIX[3].xyz;
	texture_position = world_vertex.xz/float(textureSize(heightmap_data, 0).x);
	VERTEX.y = texture(heightmap_data, texture_position).r * amplitude;
}

void fragment() {
	// Called for every pixel the material is visible on.
	//float height = global_data[VERTEX_ID];
	NORMAL_MAP = texture(normalmap_data, texture_position).rgb;
}

//void light() {
	// Called for every pixel for every light affecting the material.
	// Uncomment to replace the default light processing function with this one.
//}
