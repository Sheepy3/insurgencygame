shader_type canvas_item;

// Height of one horizontal color band, in pixels.
uniform float band_height_pixels : hint_range(1.0, 256.0, 1.0) = 16.0;

// The portion of the rect occupied by the banded A-to-B gradient.
uniform float gradient_height_percent : hint_range(0.0, 100.0, 0.1) = 50.0;

uniform vec4 color_a : source_color = vec4(0.08, 0.16, 0.30, 1.0);
uniform vec4 color_b : source_color = vec4(0.42, 0.62, 0.78, 1.0);

// Leave at 0 for a full-screen ColorRect. For a smaller ColorRect, set this
// to that rect's height in pixels so band_height_pixels stays exact.
uniform float rect_height_pixels : hint_range(0.0, 4320.0, 1.0) = 0.0;

void fragment() {
	float height_pixels = rect_height_pixels;
	if (height_pixels <= 0.0) {
		height_pixels = 1.0 / SCREEN_PIXEL_SIZE.y;
	}

	float gradient_height = height_pixels * (gradient_height_percent / 100.0);
	float band_count = max(ceil(gradient_height / band_height_pixels), 1.0);
	float band_index = floor((UV.y * height_pixels) / band_height_pixels);
	float gradient_position = band_index / max(band_count - 1.0, 1.0);

	if (gradient_height <= 0.0 || UV.y * height_pixels >= gradient_height) {
		COLOR = color_b;
	} else {
		COLOR = mix(color_a, color_b, clamp(gradient_position, 0.0, 1.0));
	}
}
