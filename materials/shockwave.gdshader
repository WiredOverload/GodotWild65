shader_type spatial;

uniform sampler2D SCREEN_TEXTURE : hint_screen_texture, filter_linear_mipmap;
uniform vec2 center;
uniform float force;
uniform float size;
uniform float thickness;

void vertex() {
	// Called for every vertex the material is visible on.
}

void fragment() {
	float sizeMod = (TIME - float(int(TIME))) * size;
	float mask = (1.0 - smoothstep(sizeMod - 0.1, sizeMod, length(UV - center))) * 
		smoothstep(sizeMod - (thickness * 2.0), sizeMod - thickness, length(UV - center));
	//float forceMod = abs(sin(TIME));
	//float forceMod = (TIME - float(int(TIME))) * 5.0;
	vec2 disp = normalize(SCREEN_UV - center) * force * mask;
	ALBEDO.r = texture(SCREEN_TEXTURE, SCREEN_UV - (disp * .5)).r;
	ALBEDO.g = texture(SCREEN_TEXTURE, SCREEN_UV - disp).g;
	ALBEDO.b = texture(SCREEN_TEXTURE, SCREEN_UV - (disp * 1.5)).b;
	//ALBEDO = tex.xyz;
}

//void light() {
	// Called for every pixel for every light affecting the material.
	// Uncomment to replace the default light processing function with this one.
//}
