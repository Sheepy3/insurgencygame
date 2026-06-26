shader_type canvas_item;

uniform float progress : hint_range(0.0, 1.0) = 0.0;
uniform float block_size = 6.0;
uniform float softness : hint_range(0.0, 0.25) = 0.06;

float hash(vec2 p) {
	return fract(sin(dot(p, vec2(127.1, 311.7))) * 43758.5453123);
}

void fragment() {
	vec4 col = texture(TEXTURE, UV);

	// Pixel coordinates in the rendered UI texture
	vec2 pixel = floor(UV / TEXTURE_PIXEL_SIZE);

	// Group into 2x2 blocks
	vec2 cell = floor(pixel / block_size);

	// Random reveal order per block
	float threshold = hash(cell);

	// Smoothly fade each block in when progress reaches its threshold
	float mask = smoothstep(threshold - softness, threshold + softness, progress);

	col.a *= mask;
	COLOR = col;
}