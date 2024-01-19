shader_type canvas_item;

uniform float strength = 16.0;
uniform int samples = 8;

uniform sampler2D SCREEN_TEXTURE : hint_screen_texture, filter_linear_mipmap;

void fragment() {
	vec4 accum = vec4(0, 0, 0, 0);
	for (int i = 0; i < samples; ++i) {
		float d = float(i) / float(samples) * strength;
		vec2 pixel_pos = (SCREEN_UV - vec2(0.5, 0.5)) / SCREEN_PIXEL_SIZE;
		mat2 rot = mat2(
			vec2(cos(d), -sin(d)),
			vec2(sin(d), cos(d)));
		pixel_pos = rot * pixel_pos;
		vec2 uv = (pixel_pos * SCREEN_PIXEL_SIZE) + vec2(0.5, 0.5);
		vec4 s = texture(SCREEN_TEXTURE, uv);
		float a = 1.0 - float(i) / float(samples);
		accum = mix(accum, s, a);
	}
	COLOR = accum;
}
