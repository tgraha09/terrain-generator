shader_type spatial;

uniform sampler2D heightmap;
uniform float height_scale = 0.1;
uniform vec3 grass_color = vec3(0.2, 0.6, 0.2); // green
uniform vec3 water_color = vec3(0.2, 0.4, 0.8); // blue
uniform vec3 dirt_color = vec3(0.6, 0.4, 0.2); // brown

uniform float water_threshold = 0.0; // height value below which is water
uniform float dirt_threshold = 0.6; // height value above which is dirt
uniform float grass_threshold = 0.01;

uniform float min_height = 0;
uniform float max_height = 1;
uniform sampler2D terrain_color;
varying float vertex_y;
varying float normal_y;



//float inverseLerp(float a, float b, float value){
//	float val = (value-a) / (b-a);
//	return clamp(0.01, 1.0, val);
//}

void vertex(){
    normal_y = NORMAL.y;
    vertex_y = VERTEX.y;
}

void fragment() {
    //ALBEDO = mix(water_color, dirt_color, dirt_threshold);
    vec3 color;
	float height_value = vertex_y;
    if (height_value < water_threshold) {
        color = water_color;
    } else if (height_value > water_threshold) {
        color = grass_color; 
    }
    ALBEDO = color;
	//float position = inverseLerp(min_height, max_height, height);
	//vec3 color = texture(terrain_color, vec(position, 0)).rgb;
	//ALBEDO = color;
    /*vec4 height = texture(heightmap, UV);
    float height_value = height.r * height_scale;

    vec3 color;
    if (height_value < water_threshold) {
        color = water_color;
    } else if (height_value > water_threshold) {
        color = grass_color;
    }

    ALBEDO = color;*/
}