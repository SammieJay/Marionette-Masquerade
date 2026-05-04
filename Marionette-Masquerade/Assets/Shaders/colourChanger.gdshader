shader_type canvas_item;

uniform vec4 color_a : source_color = vec4(0.6, 0.0, 0.8, 1.0); // purple
uniform vec4 color_b : source_color = vec4(0.0, 0.6, 1.0, 1.0); // blue
uniform float pulse_speed = 1.5;
uniform float threshold = 0.1;

void fragment() {
    vec4 tex = texture(TEXTURE, UV);

    // How dark the pixel is
    float luminance = dot(tex.rgb, vec3(0.299, 0.587, 0.114));

    // Mask for black-ish pixels
    float mask = smoothstep(threshold, 0.0, luminance);

    // Smooth pulse (0 → 1 → 0)
    float pulse = 0.5 + 0.5 * sin(TIME * pulse_speed);

    // Gradient between the two colors
    vec3 pulse_color = mix(color_a.rgb, color_b.rgb, pulse);

    // Replace only the black parts
    vec3 final_rgb = mix(tex.rgb, pulse_color, mask);

    COLOR = vec4(final_rgb, tex.a);
}

