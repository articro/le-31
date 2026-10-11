shader_type canvas_item;
// A window's fill: four corner colours shaded across the rect as the PS1 shaded a quad, then cut to
// 15 bits through the console's 4x4 dither. `pixels` is the rect's size in art pixels, which keeps
// the dither one art pixel to a cell at any scale.

uniform vec4 top_left = vec4(0.46, 0.12, 0.23, 1.0);
uniform vec4 top_right = vec4(0.64, 0.26, 0.16, 1.0);
uniform vec4 bottom_left = vec4(0.16, 0.05, 0.13, 1.0);
uniform vec4 bottom_right = vec4(0.38, 0.13, 0.09, 1.0);
uniform vec2 pixels = vec2(64.0, 64.0);
uniform float brightness : hint_range(0.0, 2.0) = 1.0;
uniform float opacity : hint_range(0.0, 1.0) = 1.0;
uniform bool dither = true;

const float DITHER[16] = float[16](-4.0, 0.0, -3.0, 1.0, 2.0, -2.0, 3.0, -1.0, -3.0, 1.0, -4.0, 0.0, 3.0, -1.0, 2.0, -2.0);

void fragment() {
	vec4 top = mix(top_left, top_right, UV.x);
	vec4 bottom = mix(bottom_left, bottom_right, UV.x);
	vec4 c = mix(top, bottom, UV.y);
	vec3 rgb = c.rgb * brightness * 255.0;
	if (dither) {
		ivec2 p = ivec2(floor(UV * pixels));
		rgb += DITHER[(p.y & 3) * 4 + (p.x & 3)];
	}
	rgb = floor(clamp(rgb, 0.0, 255.0) / 8.0) / 31.0;
	COLOR = vec4(rgb, c.a * opacity);
}
