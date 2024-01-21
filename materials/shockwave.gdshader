shader_type spatial;
render_mode unshaded;

uniform sampler2D SCREEN_TEXTURE : hint_screen_texture, filter_linear_mipmap;
uniform vec2 center;
uniform float force;
uniform float size;
uniform float thickness;

void fragment() {
	//float sizeMod = (TIME - float(int(TIME))) * size;
	float mask = (1.0 - smoothstep(size - 0.1, size, length(UV - center))) * 
		smoothstep(size - (thickness * 2.0), size - thickness, length(UV - center));
	vec2 disp = normalize(SCREEN_UV - center) * force * mask;
	ALBEDO.r = texture(SCREEN_TEXTURE, SCREEN_UV - (disp * .5)).r;
	ALBEDO.g = texture(SCREEN_TEXTURE, SCREEN_UV - disp).g;
	ALBEDO.b = texture(SCREEN_TEXTURE, SCREEN_UV - (disp * 1.5)).b;
	ALPHA = clamp(length(disp) * 10.0, 0.0, 1.0);
}
