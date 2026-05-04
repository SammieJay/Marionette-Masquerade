shader_type canvas_item;

uniform int tentacle_count = 7;
uniform float speed = 1.6;
uniform float wiggle_strength = 0.18;
uniform float taper = 2.8;
uniform float pixel_size = 200.5; 

float hash(float n) {
    return fract(sin(n) * 43758.5453123);
}

void fragment() {
    // Softer pixelation
    vec2 uv = floor(UV * pixel_size) / pixel_size;

    float alpha = 0.0;

    for (int i = 0; i < tentacle_count; i++) {
        float id = float(i);

        float rand = hash(id * 13.37);
        float phase = rand * 6.28318;
        float sway_freq = mix(6.0, 14.0, hash(id * 2.1));
        float length = mix(0.55, 1.0, hash(id * 5.7));

        if (uv.y > length) {
            continue;
        }

        float center =
            (id + 0.5) / float(tentacle_count) +
            (hash(id * 9.1) - 0.5) * 0.08;

        float wiggle =
            sin(uv.y * sway_freq + TIME * speed + phase) *
            wiggle_strength *
            (1.0 - uv.y);

        wiggle += (hash(uv.y * 50.0 + id) - 0.5) * 0.03;

        float base_width = mix(0.012, 0.03, rand);
        float width = base_width * pow(1.0 - uv.y, taper);

        float dist = abs((uv.x + wiggle) - center);

        float mask = smoothstep(width, width - 0.012, dist);

        alpha = max(alpha, mask);
    }

    COLOR = vec4(0.0, 0.0, 0.0, alpha);
}