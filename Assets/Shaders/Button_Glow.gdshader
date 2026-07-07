shader_type canvas_item;
render_mode blend_mix;

// Set state to: 0 = normal, 1 = hover, 2 = pressed, 3 = disabled.
uniform int state : hint_range(0, 3) = 0;

uniform vec4 base_color : source_color = vec4(0.55, 0.12, 0.12, 1.0);
uniform vec4 edge_color : source_color = vec4(0.25, 0.035, 0.035, 1.0);
uniform vec4 disabled_edge_color : source_color = vec4(0.12, 0.11, 0.11, 1.0);
uniform vec4 border_fade_color : source_color = vec4(0.7, 0.17, 0.17, 1.0);
uniform vec4 disabled_border_fade_color : source_color = vec4(0.15, 0.14, 0.14, 1.0);
uniform vec4 pressed_color : source_color = vec4(0.35, 0.06, 0.06, 1.0);
uniform vec4 disabled_color : source_color = vec4(0.22, 0.20, 0.20, 1.0);
uniform vec4 glow_color : source_color = vec4(1.0, 0.35, 0.25, 1.0);

uniform float edge_width_px : hint_range(0.0, 16.0) = 2.0;
uniform float border_fade_width_px : hint_range(0.0, 32.0) = 2.0;
uniform float border_noise_amount : hint_range(0.0, 0.2) = 0.3;
uniform float glow_intensity : hint_range(0.0, 2.0) = 0.9;
uniform float radius : hint_range(0.05, 1.0) = 0.65;
uniform float softness : hint_range(0.1, 8.0) = 2.5;
uniform float aspect_ratio : hint_range(0.01, 100.0) = 1.0;
uniform vec2 button_size = vec2(1.0);
uniform bool stretch_glow_to_button = true;

// A deterministic hash gives every face pixel a stable noise value.
float fixed_pixel_noise(vec2 pixel_position) {
    return fract(sin(dot(pixel_position, vec2(12.9898, 78.233)) + 41.73) * 43758.5453);
}

void fragment() {
    vec4 surface_color = base_color;

    if (state == 2) {
        surface_color = pressed_color;
    } else if (state == 3) {
        surface_color = disabled_color;
    }

    vec2 safe_size = max(button_size, vec2(1.0));

    // Fade from the face perimeter toward its center. The right and bottom
    // measurements stop where the separate bevel edge begins.
    vec2 pixel_position = UV * safe_size;
    vec2 face_end = max(safe_size - vec2(edge_width_px), vec2(0.0));
    float distance_to_face_edge = min(
        min(pixel_position.x, pixel_position.y),
        min(face_end.x - pixel_position.x, face_end.y - pixel_position.y)
    );
    distance_to_face_edge = max(distance_to_face_edge, 0.0);

    float fade_width = max(border_fade_width_px, 0.001);
    float border_fade = 1.0 - smoothstep(0.0, fade_width, distance_to_face_edge);
    vec4 active_border_color = state == 3 ? disabled_border_fade_color : border_fade_color;
    float noise = (fixed_pixel_noise(floor(pixel_position)) - 0.5) * border_noise_amount;
    active_border_color.rgb *= 1.0 + noise;
    surface_color = mix(surface_color, active_border_color, border_fade);

    // Darken the right and bottom to create the offset/bevel edge.
    vec2 edge_width_uv = vec2(edge_width_px) / safe_size;
    float right_edge = step(1.0 - edge_width_uv.x, UV.x);
    float bottom_edge = step(1.0 - edge_width_uv.y, UV.y);
    float edge_mask = max(right_edge, bottom_edge);
    vec4 active_edge_color = state == 3 ? disabled_edge_color : edge_color;
    surface_color = mix(surface_color, active_edge_color, edge_mask);

    // The glow is only visible in the hover state.
    vec2 p = UV - vec2(0.5);
    if (!stretch_glow_to_button) {
        p.x *= aspect_ratio;
    }
    float distance_from_center = length(p);
    float glow = 1.0 - smoothstep(0.0, radius, distance_from_center);
    glow = pow(glow, softness) * glow_intensity;
    glow *= 1.0 - edge_mask;

    if (state == 1) {
        surface_color.rgb += glow_color.rgb * glow * glow_color.a;
    }

    COLOR = surface_color;
}
