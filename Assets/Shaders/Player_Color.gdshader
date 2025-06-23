shader_type canvas_item;
// stolen from https://godotshaders.com/shader/tint-blend/, thank you!
// also stole saturation code from https://www.youtube.com/watch?v=Pu2muzzvS4M
uniform vec3 tint_color : source_color = vec3(1.0, 0.0, 0.0);
uniform float intensity : hint_range(0, 1) = 0.2;
uniform float saturation : hint_range(0, 30) = 1;
uniform float value      : hint_range(0, 2)  = 1.0;
mat4 saturation_matrix(float s){
	vec3 luminance = vec3(0.3086,0.6094, 0.0820);
	float sr = (1.0 - s) * luminance.r;
	float sb = (1.0 - s) * luminance.g;
	float sg = (1.0 - s) * luminance.b;
	return mat4(
		vec4(sr + s,sr,sr,0),
		vec4(sg,sg+s,sg,0),
		vec4(sb, sb, sb+s,0),
		vec4(0,0,0,1)
	);
}


void fragment(){
    vec4 front = texture(TEXTURE, UV);
    vec4 tinted = mix(front, vec4(tint_color, front.a), intensity);
    vec3 sat = (saturation_matrix(saturation) * tinted).rgb;
    sat *= value;
    COLOR = vec4(sat, front.a);
    //COLOR = saturation_matrix(saturation)*mix(front, vec4(tint_color, front.a), intensity);
}