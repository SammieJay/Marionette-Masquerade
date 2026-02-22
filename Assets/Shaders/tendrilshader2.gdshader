shader_type canvas_item;

uniform sampler2D SCREEN_TEXTURE : hint_screen_texture, filter_linear_mipmap;

// Colors
uniform vec4 color_a : source_color = vec4(0.6,0.0,0.8,1.0);
uniform vec4 color_b : source_color = vec4(0.0,0.6,1.0,1.0);

// Black pixel threshold
uniform float threshold = 0.1;

// Tendril parameters
uniform int tendril_count = 100;           // More tendrils = thinner
uniform float tendril_speed = 2.0;
uniform float tendril_strength = 0.05;    // Smaller strength = thinner
uniform float tendril_length_scale = 1.0;
uniform float curl_frequency = 12.0;
uniform float curl_strength = 0.1;        // Less curl for thin strands
uniform float wiggle_frequency = 15.0;    // Higher = more fine wiggle
uniform float wiggle_amplitude = 0.1;

// Pixelation (optional)
uniform float pixel_size = 0.0;

// Color pulse
uniform float pulse_speed = 2.0;

// Random helper
float rand(float x){ return fract(sin(x*43758.5453)); }

void fragment(){
    vec4 screen_color = texture(SCREEN_TEXTURE, SCREEN_UV);

    // Mask black pixels
    float luminance = dot(screen_color.rgb, vec3(0.299,0.587,0.114));
    float mask = smoothstep(threshold,0.0,luminance);

    if(mask < 0.001){
        COLOR = vec4(0.0,0.0,0.0,0.0);
    } else {
        vec2 uv = SCREEN_UV;
        if(pixel_size>0.0){
            uv = floor(uv*pixel_size)/pixel_size;
        }

        float slither = 0.0;

        for(int i=0;i<tendril_count;i++){
            float idx = float(i);

            // Pick screen edge: 0=top,1=bottom,2=left,3=right
            float edge = floor(rand(idx)*4.0);
            vec2 origin;
            if(edge==0.0){ origin = vec2(rand(idx+10.0),0.0); }
            else if(edge==1.0){ origin = vec2(rand(idx+10.0),1.0); }
            else if(edge==2.0){ origin = vec2(0.0,rand(idx+10.0)); }
            else{ origin = vec2(1.0,rand(idx+10.0)); }

            vec2 rel = uv - origin;
            float dist = length(rel);

            // Attenuation
            float attenuation = clamp(1.0 - dist*tendril_length_scale, 0.0, 1.0);

            // Tendril wiggle & curl
            float angle = atan(rel.y,rel.x) + rand(idx+20.0)*6.283185;
            float x_rot = rel.x*cos(angle) - rel.y*sin(angle);
            float y_rot = rel.x*sin(angle) + rel.y*cos(angle);

            float wave = sin(y_rot*wiggle_frequency + sin(x_rot*wiggle_frequency + rand(idx+30.0)) + TIME*tendril_speed*(0.5+rand(idx)*0.5));
            wave += sin(x_rot*curl_frequency + TIME*tendril_speed*(0.5+rand(idx+40.0)))*curl_strength;

            slither += wave*tendril_strength*attenuation;
        }

        slither /= float(tendril_count);
        slither = 0.5 + 0.5*slither;

        float pulse = 0.5 + 0.5*sin(TIME*pulse_speed);
        vec3 final_rgb = mix(color_a.rgb,color_b.rgb,pulse)*slither;

        COLOR = vec4(final_rgb,mask);
    }
}
