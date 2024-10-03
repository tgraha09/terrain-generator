shader_type spatial;
render_mode shadows_disabled; //cullfront
#define MAX_STEPS 150
#define MAX_DISTANCE 50.
#define SURFACE_DISTANCE .001

uniform vec3 albedo : source_color;
uniform vec3 albedo2 : source_color;
uniform float metallic : hint_range(0.0, 1.0) = 0;
uniform float roughness : hint_range(0.0, 1.0) = 0.02;
uniform sampler2D wave;

uniform sampler2D normal_noise_texture1: hint_default_black;
uniform sampler2D normal_noise_texture2: hint_default_black;
uniform float normal_scale : hint_range(0, 10) = 1.0;
uniform float wave_speed : hint_range(0, 10) = 1.0;
uniform float wave_amplitude : hint_range(0, 1) = 0.1;

uniform vec2 wave_direction1 = vec2(2.0,0.0); // Direction of wave 1
uniform vec2 wave_direction2 = vec2(0.0,1.0); // Direction of wave 2
uniform float time_scale : hint_range(0.0, 0.2, 0.005) = 0.025; // Rate of movement multiplied by TIME
uniform float noise_scale = 10.0;
uniform float height_scale = 0.15;

uniform vec4 color_deep : source_color; // Deep depth color
uniform vec4 color_shallow : source_color; // Shallow depth color
uniform float beers_law = 2.0; // Beer's law application
uniform float depth_offset = -0.75; // Offset
uniform float depth_density = 1; // Beer's law application

uniform float foam_thickness: hint_range(0.0, 1.0, 0.01) = 0.5;
uniform float foam_intensity = 3;

uniform float edge_scale = 0.1;
uniform float near = 1.0;
uniform float far = 100.0;
uniform vec3 edge_color : source_color;

uniform sampler2D SCREEN_TEXTURE: hint_screen_texture;
uniform sampler2D DEPTH_TEXTURE : hint_depth_texture, filter_linear_mipmap;
// Varying variables
varying float height;
varying vec3 world_pos;

varying vec3 vertex_ls;
varying mat3 model_view_matrix;



float fresnel(float amount, vec3 normal, vec3 view)
{
	return pow((1.0 - clamp(dot(normalize(normal), normalize(view)), 0.0, 1.0 )), amount);
}
float edge(float depth){
	depth = 2.0 * depth - 1.0;
	return near * far / (far + depth * (near - far));
}



void vertex() {
	world_pos = (MODEL_MATRIX * vec4(VERTEX, 1.0)).xyz;
	height = texture(wave, world_pos.xz / noise_scale + TIME * time_scale).r;
	VERTEX.y += height * height_scale;
	vertex_ls = VERTEX;
	model_view_matrix = mat3(MODELVIEW_MATRIX);
}

void fragment() {
	float depth = texture(DEPTH_TEXTURE, SCREEN_UV).r;
	//depth *= 2.0 - 1.0;
	depth =  PROJECTION_MATRIX[3].z / (depth + PROJECTION_MATRIX[2].z) + VERTEX.z;
	//depth = exp(-depth * depth_density);

	vec2 time1 = (TIME * wave_direction1) * time_scale; // Movement rate of first wave
	vec2 time2 = (TIME * wave_direction2) * time_scale; // Movement rate of second wave
	vec3 normals = mix(texture(normal_noise_texture1,world_pos.xz + time1).rgb, texture(normal_noise_texture2,world_pos.xz + time2).rgb, 0.5);
	// Depth variables and calc
	/*float depth = texture(DEPTH_TEXTURE, SCREEN_UV).r;
	float depth_blend = clamp(depth, 0.0, 1.0);

	// Getting edge depth calc
	float z_depth = edge(texture(DEPTH_TEXTURE, SCREEN_UV).x);
	float z_pos = edge(FRAGCOORD.z);
	float z_dif = z_depth - z_pos;

	//float edgeThreshold = 0.1; // adjust this value to control the sensitivity of the edge detection
	float edgeStrength = step(edge_scale, abs(z_dif));

    // Blend the colors
    vec3 screen_color = textureLod(SCREEN_TEXTURE, SCREEN_UV, depth_blend * 2.5).rgb;
    vec3 depth_color = mix(color_shallow.rgb, color_deep.rgb, depth_blend);


	vec2 time1 = (TIME * wave_direction1) * time_scale; // Movement rate of first wave
	vec2 time2 = (TIME * wave_direction2) * time_scale; // Movement rate of second wave

	// Blend normal maps into one
	vec3 normal_blend = mix(texture(normal_noise_texture1,world_pos.xz + time1).rgb, texture(normal_noise_texture2,world_pos.xz + time2).rgb, 0.5);
    vec3 final_normal = normal_blend;//normalize(normal1 + normal2);

	float fresnel = fresnel(5.0, NORMAL, VIEW);
	vec3 surface_color = mix(albedo, albedo2, fresnel);



	// Blend the surface color with the depth color
    vec3 final_color = mix(surface_color, depth_color, depth_blend);
	final_color = mix(final_color, edge_color, edgeStrength);*/

	//	vec3 screen_color = textureLod(SCREEN_TEXTURE, SCREEN_UV, depth_blend_power * 2.5).rgb;
	//vec3 depth_color = mix(color_shallow.rgb, color_deep.rgb, depth_blend_power);
	//vec3 color = mix(screen_color * depth_color, depth_color * 0.25, depth_blend_power * 0.5);

    //ALBEDO = final_color; // base color
	float fresnel = fresnel(5.0, NORMAL, VIEW);
	vec3 water_color = mix(albedo, albedo2, fresnel);


	float foam = smoothstep(1. - foam_thickness, 1, depth) * foam_intensity;
	vec3 final_color = mix(water_color, vec3(-depth), exp(-depth * depth_density));
	//final_color = mix(water_color, vec3(-foam), exp(-depth * foam_intensity));

	ALBEDO = final_color; // base color
	//ALBEDO = vec3(foam); // base color
	//ALPHA = 1. -depth;
   	NORMAL = model_view_matrix * normals;
	METALLIC = metallic;
	ROUGHNESS = roughness;
}