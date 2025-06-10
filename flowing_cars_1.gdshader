shader_type spatial;
render_mode unshaded;

uniform vec3 base_color : source_color = vec3(0.1, 0.2, 0.3);
uniform float base_emission : hint_range(0.0, 10.0) = 1.0;

uniform vec3 orb_color : source_color = vec3(0.8, 1.0, 0.7);
uniform float orb_emission : hint_range(0.0, 20.0) = 5.0;
uniform int orb_count : hint_range(1, 10) = 3;
uniform float orb_size : hint_range(0.01, 0.5) = 0.15;
uniform float orb_speed : hint_range(0.1, 5.0) = 1.0;
uniform float orb_blend : hint_range(0.1, 2.0) = 1.0;

void fragment() {
    // Use UV.x as the "along the road" axis, UV.y as across
    float t = TIME * orb_speed;
    float meta = 0.0;
    for (int i = 0; i < orb_count; i++) {
        // Each orb is offset along the road
        float phase = float(i) / float(orb_count);
        float pos = mod(t + phase, 1.0);
        // Distance from this orb center in UV space
        float d = distance(vec2(UV.x, UV.y), vec2(pos, 0.5));
        // Meta-orb: soft, blobby falloff
        meta += exp(-pow(d / orb_size, orb_blend));
    }
    meta = clamp(meta, 0.0, 1.0);

    // Combine base and orb color
    vec3 color = mix(base_color, orb_color, meta);
    float emission = mix(base_emission, orb_emission, meta);

    ALBEDO = color;
    EMISSION = color * emission;
}