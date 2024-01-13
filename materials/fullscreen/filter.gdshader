// Converted from https://www.shadertoy.com/view/td2GzW
shader_type canvas_item;
uniform sampler2D SCREEN_TEXTURE : hint_screen_texture, filter_linear_mipmap;

// Anti fish eye (negative amount) / fish eye (positive)
uniform float fisheye_power : hint_range(-2.5, 2.5) = 1.0;

uniform float scanline_scale : hint_range(0.01, 10.0) = 4.0;
uniform float scanline_ratio : hint_range(0.0, 1.0) = 0.5;
uniform float scanline_sharpness : hint_range(0.0, 1.0) = 0.5;
uniform float scanline_timescale : hint_range(-10.0, 10.0) = 0.0;
uniform float scanline_strength : hint_range(0.0, 1.0) = 0.3;

vec2 fisheye(vec2 frag_coord, vec2 pixel_size, vec2 center) {
	vec2 pixel_coord = frag_coord.xy * pixel_size.x;
	float aspect_ratio = pixel_size.y / pixel_size.x;
	center = center / vec2(1.0, aspect_ratio);
	vec2 to_center = pixel_coord - center;
	float dist_to_center = length(to_center);
	
	//stick to borders
	float bind =
		(fisheye_power > 0.0) ? length(center) :
		((aspect_ratio < 1.0) ? center.x :
		center.y);
	
	vec2 uv;
	//fisheye
	if (fisheye_power > 0.0)
		uv = center + normalize(to_center) * tan(dist_to_center * fisheye_power) * bind / tan( bind * fisheye_power);
	//antifisheye
	else if (fisheye_power < 0.0)
		uv = center + normalize(to_center) * atan(dist_to_center * -fisheye_power * 10.0) * bind / atan(-fisheye_power * bind * 10.0);
	//no effect for fisheye_power = 1.0
	else
		uv = pixel_coord;
	uv.y *= aspect_ratio;
	
	return uv;
}

float scanline(vec2 frag_coord) {
	float y = frag_coord.y / scanline_scale - TIME * scanline_timescale;
	float closest = round(y);
	float max_edge = scanline_ratio / 2.0;
	float t = smoothstep(scanline_sharpness * max_edge, max_edge, abs(y - closest));
	return mix(1.0 - scanline_strength, 1.0, t);
}

void fragment() {
	vec2 uv = fisheye(FRAGCOORD.xy, SCREEN_PIXEL_SIZE, vec2(0.5, 0.5));
	vec3 fish = texture(SCREEN_TEXTURE, uv).rgb;
	float scan = scanline(uv / SCREEN_PIXEL_SIZE);
	COLOR = vec4(fish * scan, 1.0);
}
