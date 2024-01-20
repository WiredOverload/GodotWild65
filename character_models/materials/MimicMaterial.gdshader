shader_type spatial;
render_mode unshaded, blend_mix;

uniform sampler2D albedo_texture : filter_linear;
uniform sampler3D noise_texture : filter_linear;

varying vec3 position;
varying vec3 normal;

void vertex() {
	position = VERTEX;
	normal = NORMAL;
}

void fragment() {
	vec2 ppos = SCREEN_UV * VIEWPORT_SIZE / 300.0;
	float effect = texture(noise_texture, vec3(ppos, TIME / 15.0)).r;
	vec2 offset = vec2(dFdx(effect), dFdy(effect));
	
	vec2 uv = ppos + offset;
	
	ALBEDO = texture(albedo_texture, uv).rgb;
}
