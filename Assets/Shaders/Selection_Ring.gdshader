shader_type canvas_item;

//const float PI = 3.14159265359;

// Center of the ring in UV space (0–1).
uniform vec2 center = vec2(0.5, 0.5);
// Outer radius of the ring (along X before skew)
uniform float radius : hint_range(0.0, 0.5) = 0.4;
// Thickness of the ring (outer – inner)
uniform float thickness : hint_range(0.0, 0.5) = 0.05;
// Skew factor along the Y‑axis for oval shape
uniform float skew : hint_range(0.1, 5.0) = 1.0;
// Number of dashes around the circumference
uniform int segments : hint_range(1, 100) = 20;
// Fraction of each segment that is drawn (e.g. 0.5 = half‑on, half‑gap)
uniform float dash_size : hint_range(0.0, 1.0) = 0.4;
// Rotation speed (segments per second)
uniform float speed : hint_range(-10.0, 10.0) = 1.0;
// Ring color
uniform vec4 color : source_color = vec4(1.0,1.0,1.0,1.0);

void fragment() {
    // 1) transform to skewed space and measure distance
    vec2 p = UV - center;
    p.y *= skew;
    float d = length(p);

    // 2) ring bounds
    float inner_r = max(radius - thickness, 0.0);
    if (d < inner_r || d > radius) {
        discard;
    }

    // 3) compute normalized angle [0,1)
    float ang  = atan(p.y, p.x);            // –π … +π
    float norm = (ang + PI) / (2.0 * PI);   //  0 … 1

    // 4) turn that into segment-relative t in [0,1), offset by time
    float seg_pos = norm * float(segments);
    float t       = fract(seg_pos - TIME * speed);

    // 5) dash gating
    if (t > dash_size) {
        discard;
    }

    // 6) if we haven’t discarded, draw the pixel
    COLOR = color;
}
