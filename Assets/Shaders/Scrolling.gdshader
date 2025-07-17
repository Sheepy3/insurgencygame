shader_type canvas_item;

/* ────────────────────────────────  SCROLL  ──────────────────────────────── */
uniform sampler2D texture_to_scroll : filter_nearest, repeat_enable;

uniform float pixel_speed     = 40.0;                 // pixels / second
uniform float angle_degrees   : hint_range(0,360) = 0.0;
uniform float sprite_width_px = 256.0;                // sprite's pixel width

uniform float repeat_x        : hint_range(1,20)  = 20.0;
uniform float repeat_y        : hint_range(1,20)  = 12.0;
uniform float row_offset      : hint_range(0,1)   = 1.0;

/* ────────────────────────────────   TINT  ──────────────────────────────── */
uniform vec3  tint_color  : source_color       = vec3(1.0, 0.0, 0.0);
uniform float tint_mix    : hint_range(0,1)    = 0.5;   // 0 = original, 1 = pure tint
uniform float saturation  : hint_range(0, 3)   = 1.0;   // 1 = unchanged
uniform float value       : hint_range(0, 3)   = 1.0;   // brightness‑scale

/* Helper that returns a 4×4 saturation‑adjustment matrix */
mat4 saturation_matrix(float s){
    vec3 lum = vec3(0.3086, 0.6094, 0.0820);      // NTSC luma weights
    float inv = 1.0 - s;

    return mat4(
        vec4(lum.r * inv + s, lum.r * inv,     lum.r * inv,     0.0),
        vec4(lum.g * inv,     lum.g * inv + s, lum.g * inv,     0.0),
        vec4(lum.b * inv,     lum.b * inv,     lum.b * inv + s, 0.0),
        vec4(0.0,             0.0,             0.0,             1.0)
    );
}

/* ───────────────────────────────  FRAGMENT  ─────────────────────────────── */
void fragment () {

    /* --- scrolling UV ----------------------------------------------------- */
    float angle = radians(angle_degrees);
    vec2  dir   = vec2(cos(angle), sin(angle));

    float uv_speed = pixel_speed / sprite_width_px;
    vec2 uv = UV - TIME * uv_speed * dir;

    /*  "brick" row offset (every other row shifted right) */
    float tileW  = 1.0 / repeat_x;
    if (mod(floor(uv.y * repeat_y), 2.0) > 0.0){
        uv.x += row_offset * tileW;              // half‑tile shift by default
    }

    uv = fract(uv * vec2(repeat_x, repeat_y));   // wrap into 0‑1

    /* --- fetch the pixel -------------------------------------------------- */
    vec4 col = texture(texture_to_scroll, uv);

    /* --- tint / saturation / value ---------------------------------------- */
    vec4 tinted = mix(col, vec4(tint_color, col.a), tint_mix);     // basic tint
    vec3 sat    = (saturation_matrix(saturation) * tinted).rgb;    // saturation
    sat *= value;                                                  // brightness

    COLOR = vec4(sat, col.a);   // keep original alpha
}
