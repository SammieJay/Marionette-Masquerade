shader_type canvas_item;

uniform vec4 target_color : source_color;
uniform vec4 replace_color : source_color;
uniform float tolerance : hint_range(0.0, 1.0) = 0.05;

vec3 quantize(vec3 c) {
    return floor(c * 255.0 + 0.5) / 255.0;
}

void fragment() {
    vec4 tex_color = texture(TEXTURE, UV);

    vec3 tex_q = quantize(tex_color.rgb);
    vec3 target_q = quantize(target_color.rgb);

    if (distance(tex_q, target_q) <= tolerance) {
        COLOR = vec4(replace_color.rgb, tex_color.a) * COLOR;
    } else {
        COLOR = vec4(abs(tex_color.rgb - target_color.rgb) * 5.0, 1.0);
    }
}
