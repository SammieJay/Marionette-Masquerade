shader_type canvas_item;

uniform sampler2D SCREEN_TEXTURE : hint_screen_texture, filter_linear_mipmap;

// Colors
uniform vec4 color_a : source_color = vec4(0.6, 0.0, 0.8, 1.0);
uniform vec4 color_b : source_color = vec4(0.0, 0.6, 1.0, 1.0);

// Black pixel threshold
uniform float threshold = 0.1;

// Tendril parameters
uniform int tendril_count = 50;         // number of small tendrils
uniform float tendril_length_scale = 15.0;
uniform float tendril_speed = 2.0;
uniform float tendril_strength = 0.3;
uniform float curl_frequency = 12.0;
uniform float curl_strength = 0.2;
uniform float wiggle_frequency = 8.0;
uniform float wiggle_amplitude = 0.2;

// Pixelation (optional)
uniform float pixel_size = 200.0;

// Color pulse
uniform float pulse_speed = 2.0;

// Deterministic random
float rand(float x) { return fract(sin(x*43758.5453)); }

void fragment() {
    vec4 screen_color = texture(SCREEN_TEXTURE, SCREEN_UV);

    // Detect black pixels
    float luminance = dot(screen_color.rgb, vec3(0.299,0.587,0.114));
    float mask = smoothstep(threshold, 0.0, luminance);

    if(mask < 0.001){
        COLOR = vec4(0.0,0.0,0.0,0.0);
    } else {
        // Pixelated UVs (optional)
        vec2 uv = floor(SCREEN_UV * pixel_size)/pixel_size;

        float slither = 0.0;

        for(int i=0;i<tendril_count;i++){
            float idx = float(i);

            // Random angle for each tendril
            float angle = rand(idx)*6.283185;

            // Rotate coordinates
            float x_rot = uv.x*cos(angle) - uv.y*sin(angle);
            float y_rot = uv.x*sin(angle) + uv.y*cos(angle);

            // Each tendril has its own phase offset
            float phase = rand(idx+10.0)*6.283185;

            // Small tendril wiggle + curl
            float wave = sin(y_rot*tendril_length_scale + sin(x_rot*wiggle_frequency + phase) + TIME*tendril_speed*(0.5 + rand(idx)*0.5));
            wave += sin(x_rot*curl_frequency + TIME*tendril_speed*(0.5 + rand(idx+20.0)*0.5))*curl_strength;

            // Scale by tendril strength
            slither += wave*tendril_strength;
        }

        // Average tendrils
        slither /= float(tendril_count);

        // Color pulse
        float pulse = 0.5 + 0.5*sin(TIME*pulse_speed);
        vec3 final_rgb = mix(color_a.rgb,color_b.rgb,pulse)*slither;

        COLOR = vec4(final_rgb,mask);
    }
}
