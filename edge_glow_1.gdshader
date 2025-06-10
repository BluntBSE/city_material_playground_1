shader_type spatial;
//render_mode unshaded;

uniform vec3 edge_color : source_color = vec3(0.2, 1.0, 1.0); // Neon cyan
uniform float edge_strength : hint_range(0.0, 10.0) = 3.0;
uniform float edge_width : hint_range(0.01, 1.0) = 0.2;
uniform float edge_emission : hint_range(0.0, 10.0) = 2.0;
uniform vec3 base_color : source_color = vec3(0.05, 0.05, 0.05);

void fragment() {
    // Fresnel term: highlights edges facing away from camera
    float fresnel = pow(1.0 - dot(NORMAL, VIEW), edge_strength);
    float edge = smoothstep(1.0 - edge_width, 1.0, fresnel);

    // Neon edge color
    vec3 neon = edge_color * edge * edge_emission;

    // Combine with base color
    ALBEDO = base_color + neon;
    EMISSION = neon;
}