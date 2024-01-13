// Converted from https://www.shadertoy.com/view/td2GzW
shader_type canvas_item;
uniform sampler2D SCREEN_TEXTURE : hint_screen_texture, filter_linear_mipmap;

// Anti fish eye (negative amount) / fish eye (positive)
uniform float fisheye_power : hint_range(-2.5, 2.5) = 1.0;

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
	float y = frag_coord.y / 4.0 - TIME;
	float closest = round(y / 2.0) * 2.0;
	float t = smoothstep(0.0, 1.0, abs(y - closest));
	return mix(0.7, 1.0, t);
}

void fragment() {
	vec2 uv = fisheye(FRAGCOORD.xy, SCREEN_PIXEL_SIZE, vec2(0.5, 0.5));
	vec3 fish = texture(SCREEN_TEXTURE, uv).rgb;
	float scan = scanline(uv / SCREEN_PIXEL_SIZE);
	COLOR = vec4(fish * scan, 1.0);
}
