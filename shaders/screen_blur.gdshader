shader_type canvas_item;

uniform float intensity : hint_range(0.0, 20.0) = 6.0;
uniform float darken : hint_range(0.0, 1.0) = 0.45;

void fragment() {
	vec2 ps = SCREEN_PIXEL_SIZE;
	vec4 c = texture(SCREEN_TEXTURE, SCREEN_UV);
	c += texture(SCREEN_TEXTURE, SCREEN_UV + vec2(intensity * ps.x, 0.0));
	c += texture(SCREEN_TEXTURE, SCREEN_UV - vec2(intensity * ps.x, 0.0));
	c += texture(SCREEN_TEXTURE, SCREEN_UV + vec2(0.0, intensity * ps.y));
	c += texture(SCREEN_TEXTURE, SCREEN_UV - vec2(0.0, intensity * ps.y));
	c += texture(SCREEN_TEXTURE, SCREEN_UV + vec2(intensity * ps.x, intensity * ps.y));
	c += texture(SCREEN_TEXTURE, SCREEN_UV - vec2(intensity * ps.x, intensity * ps.y));
	c += texture(SCREEN_TEXTURE, SCREEN_UV + vec2(-intensity * ps.x, intensity * ps.y));
	c += texture(SCREEN_TEXTURE, SCREEN_UV - vec2(-intensity * ps.x, intensity * ps.y));
	c /= 9.0;
	COLOR = mix(c, vec4(0.0), darken);
}
