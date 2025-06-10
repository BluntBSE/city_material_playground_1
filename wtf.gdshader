shader_type spatial;

render_mode unshaded, blend_mix;

uniform vec3 uv1_scale = vec3(1.0, 1.0, 1.0);
uniform vec3 uv1_offset = vec3(0.0, 0.0, 0.0);
uniform float variation = 0.0;
varying float elapsed_time;
void vertex() {
	elapsed_time = TIME;
	UV = UV*uv1_scale.xy+uv1_offset.xy;
}
float rand(vec2 x) {
    return fract(cos(mod(dot(x, vec2(13.9898, 8.141)), 3.14)) * 43758.5453);
}
vec2 rand2(vec2 x) {
    return fract(cos(mod(vec2(dot(x, vec2(13.9898, 8.141)),
						      dot(x, vec2(3.4562, 17.398))), vec2(3.14))) * 43758.5453);
}
vec3 rand3(vec2 x) {
    return fract(cos(mod(vec3(dot(x, vec2(13.9898, 8.141)),
							  dot(x, vec2(3.4562, 17.398)),
                              dot(x, vec2(13.254, 5.867))), vec3(3.14))) * 43758.5453);
}
float param_rnd(float minimum, float maximum, float seed) {
	return minimum+(maximum-minimum)*rand(vec2(seed));
}
vec3 rgb2hsv(vec3 c) {
	vec4 K = vec4(0.0, -1.0 / 3.0, 2.0 / 3.0, -1.0);
	vec4 p = c.g < c.b ? vec4(c.bg, K.wz) : vec4(c.gb, K.xy);
	vec4 q = c.r < p.x ? vec4(p.xyw, c.r) : vec4(c.r, p.yzx);
	float d = q.x - min(q.w, q.y);
	float e = 1.0e-10;
	return vec3(abs(q.z + (q.w - q.y) / (6.0 * d + e)), d / (q.x + e), q.x);
}
vec3 hsv2rgb(vec3 c) {
	vec4 K = vec4(1.0, 2.0 / 3.0, 1.0 / 3.0, 3.0);
	vec3 p = abs(fract(c.xxx + K.xyz) * 6.0 - K.www);
	return c.z * mix(K.xxx, clamp(p - K.xxx, 0.0, 1.0), c.y);
}
float pingpong(float a, float b)
{
  return (b != 0.0) ? abs(fract((a - b) / (b * 2.0)) * b * 2.0 - b) : 0.0;
}
float shape_circle(vec2 uv, float sides, float size, float edge) {
	uv = 2.0*uv-1.0;
	edge = max(edge, 1.0e-8);
	float distance = length(uv);
	return clamp((1.0-distance/size)/edge, 0.0, 1.0);
}
float shape_polygon(vec2 uv, float sides, float size, float edge) {
	uv = 2.0*uv-1.0;
	edge = max(edge, 1.0e-8);
	float angle = atan(uv.x, uv.y)+3.14159265359;
	float slice = 6.28318530718/sides;
	return clamp((1.0-(cos(floor(0.5+angle/slice)*slice-angle)*length(uv))/size)/edge, 0.0, 1.0);
}
float shape_star(vec2 uv, float sides, float size, float edge) {
	uv = 2.0*uv-1.0;
	edge = max(edge, 1.0e-8);
	float angle = atan(uv.x, uv.y);
	float slice = 6.28318530718/sides;
	return clamp((1.0-(cos(floor(angle*sides/6.28318530718-0.5+2.0*step(fract(angle*sides/6.28318530718), 0.5))*slice-angle)*length(uv))/size)/edge, 0.0, 1.0);
}
float shape_curved_star(vec2 uv, float sides, float size, float edge) {
	uv = 2.0*uv-1.0;
	edge = max(edge, 1.0e-8);
	float angle = 2.0*(atan(uv.x, uv.y)+3.14159265359);
	float slice = 6.28318530718/sides;
	return clamp((1.0-cos(floor(0.5+0.5*angle/slice)*2.0*slice-angle)*length(uv)/size)/edge, 0.0, 1.0);
}
float shape_rays(vec2 uv, float sides, float size, float edge) {
	uv = 2.0*uv-1.0;
	edge = 0.5*max(edge, 1.0e-8)*size;
	float slice = 6.28318530718/sides;
	float angle = mod(atan(uv.x, uv.y)+3.14159265359, slice)/slice;
	return clamp(min((size-angle)/edge, angle/edge), 0.0, 1.0);
}
vec2 transform2_clamp(vec2 uv) {
	return clamp(uv, vec2(0.0), vec2(1.0));
}
vec2 transform2(vec2 uv, vec2 translate, float rotate, vec2 scale) {
 	vec2 rv;
	uv -= translate;
	uv -= vec2(0.5);
	rv.x = cos(rotate)*uv.x + sin(rotate)*uv.y;
	rv.y = -sin(rotate)*uv.x + cos(rotate)*uv.y;
	rv /= scale;
	rv += vec2(0.5);
	return rv;	
}
vec2 get_from_tileset(float count, float seed, vec2 uv) {
	return clamp((uv+floor(rand2(vec2(seed))*count))/count, vec2(0.0), vec2(1.0));
}
vec2 custom_uv_transform(vec2 uv, vec2 cst_scale, float rnd_rotate, float rnd_scale, vec2 seed) {
	seed = rand2(seed);
	uv -= vec2(0.5);
	float angle = (seed.x * 2.0 - 1.0) * rnd_rotate;
	float ca = cos(angle);
	float sa = sin(angle);
	uv = vec2(ca*uv.x+sa*uv.y, -sa*uv.x+ca*uv.y);
	uv *= (seed.y-0.5)*2.0*rnd_scale+1.0;
	uv /= cst_scale;
	uv += vec2(0.5);
	return uv;
}
vec3 rgb_to_hsv(vec3 c) {
	vec4 K = vec4(0.0, -1.0 / 3.0, 2.0 / 3.0, -1.0);
	vec4 p = c.g < c.b ? vec4(c.bg, K.wz) : vec4(c.gb, K.xy);
	vec4 q = c.r < p.x ? vec4(p.xyw, c.r) : vec4(c.r, p.yzx);
	float d = q.x - min(q.w, q.y);
	float e = 1.0e-10;
	return vec3(abs(q.z + (q.w - q.y) / (6.0 * d + e)), d / (q.x + e), q.x);
}
vec3 hsv_to_rgb(vec3 c) {
	vec4 K = vec4(1.0, 2.0 / 3.0, 1.0 / 3.0, 3.0);
	vec3 p = abs(fract(c.xxx + K.xyz) * 6.0 - K.www);
	return c.z * mix(K.xxx, clamp(p - K.xxx, 0.0, 1.0), c.y);
}
vec3 blend_normal(vec2 uv, vec3 c1, vec3 c2, float opacity) {
	return opacity*c1 + (1.0-opacity)*c2;
}
vec3 blend_dissolve(vec2 uv, vec3 c1, vec3 c2, float opacity) {
	if (rand(uv) < opacity) {
		return c1;
	} else {
		return c2;
	}
}
vec3 blend_multiply(vec2 uv, vec3 c1, vec3 c2, float opacity) {
	return opacity*c1*c2 + (1.0-opacity)*c2;
}
vec3 blend_screen(vec2 uv, vec3 c1, vec3 c2, float opacity) {
	return opacity*(1.0-(1.0-c1)*(1.0-c2)) + (1.0-opacity)*c2;
}
float blend_overlay_f(float c1, float c2) {
	return (c1 < 0.5) ? (2.0*c1*c2) : (1.0-2.0*(1.0-c1)*(1.0-c2));
}
vec3 blend_overlay(vec2 uv, vec3 c1, vec3 c2, float opacity) {
	return opacity*vec3(blend_overlay_f(c1.x, c2.x), blend_overlay_f(c1.y, c2.y), blend_overlay_f(c1.z, c2.z)) + (1.0-opacity)*c2;
}
vec3 blend_hard_light(vec2 uv, vec3 c1, vec3 c2, float opacity) {
	return opacity*0.5*(c1*c2+blend_overlay(uv, c1, c2, 1.0)) + (1.0-opacity)*c2;
}
float blend_soft_light_f(float c1, float c2) {
	return (c2 < 0.5) ? (2.0*c1*c2+c1*c1*(1.0-2.0*c2)) : 2.0*c1*(1.0-c2)+sqrt(c1)*(2.0*c2-1.0);
}
vec3 blend_soft_light(vec2 uv, vec3 c1, vec3 c2, float opacity) {
	return opacity*vec3(blend_soft_light_f(c1.x, c2.x), blend_soft_light_f(c1.y, c2.y), blend_soft_light_f(c1.z, c2.z)) + (1.0-opacity)*c2;
}
float blend_burn_f(float c1, float c2) {
	return (c1==0.0)?c1:max((1.0-((1.0-c2)/c1)),0.0);
}
vec3 blend_burn(vec2 uv, vec3 c1, vec3 c2, float opacity) {
	return opacity*vec3(blend_burn_f(c1.x, c2.x), blend_burn_f(c1.y, c2.y), blend_burn_f(c1.z, c2.z)) + (1.0-opacity)*c2;
}
float blend_dodge_f(float c1, float c2) {
	return (c1==1.0)?c1:min(c2/(1.0-c1),1.0);
}
vec3 blend_dodge(vec2 uv, vec3 c1, vec3 c2, float opacity) {
	return opacity*vec3(blend_dodge_f(c1.x, c2.x), blend_dodge_f(c1.y, c2.y), blend_dodge_f(c1.z, c2.z)) + (1.0-opacity)*c2;
}
vec3 blend_lighten(vec2 uv, vec3 c1, vec3 c2, float opacity) {
	return opacity*max(c1, c2) + (1.0-opacity)*c2;
}
vec3 blend_darken(vec2 uv, vec3 c1, vec3 c2, float opacity) {
	return opacity*min(c1, c2) + (1.0-opacity)*c2;
}
vec3 blend_difference(vec2 uv, vec3 c1, vec3 c2, float opacity) {
	return opacity*clamp(c2-c1, vec3(0.0), vec3(1.0)) + (1.0-opacity)*c2;
}
vec3 blend_additive(vec2 uv, vec3 c1, vec3 c2, float oppacity) {
	return c2 + c1 * oppacity;
}
vec3 blend_addsub(vec2 uv, vec3 c1, vec3 c2, float oppacity) {
	return c2 + (c1 - .5) * 2.0 * oppacity;
}
float blend_linear_light_f(float c1, float c2) {
	return (c1 + 2.0 * c2) - 1.0;
}
vec3 blend_linear_light(vec2 uv, vec3 c1, vec3 c2, float opacity) {
return opacity*vec3(blend_linear_light_f(c1.x, c2.x), blend_linear_light_f(c1.y, c2.y), blend_linear_light_f(c1.z, c2.z)) + (1.0-opacity)*c2;
}
float blend_vivid_light_f(float c1, float c2) {
	return (c1 < 0.5) ? 1.0 - (1.0 - c2) / (2.0 * c1) : c2 / (2.0 * (1.0 - c1));
}
vec3 blend_vivid_light(vec2 uv, vec3 c1, vec3 c2, float opacity) {
	return opacity*vec3(blend_vivid_light_f(c1.x, c2.x), blend_vivid_light_f(c1.y, c2.y), blend_vivid_light_f(c1.z, c2.z)) + (1.0-opacity)*c2;
}
float blend_pin_light_f( float c1, float c2) {
	return (2.0 * c1 - 1.0 > c2) ? 2.0 * c1 - 1.0 : ((c1 < 0.5 * c2) ? 2.0 * c1 : c2);
}
vec3 blend_pin_light(vec2 uv, vec3 c1, vec3 c2, float opacity) {
	return opacity*vec3(blend_pin_light_f(c1.x, c2.x), blend_pin_light_f(c1.y, c2.y), blend_pin_light_f(c1.z, c2.z)) + (1.0-opacity)*c2;
}
float blend_hard_mix_f(float c1, float c2) {
	return floor(c1 + c2);
}
vec3 blend_hard_mix(vec2 uv, vec3 c1, vec3 c2, float opacity) {
		return opacity*vec3(blend_hard_mix_f(c1.x, c2.x), blend_hard_mix_f(c1.y, c2.y), blend_hard_mix_f(c1.z, c2.z)) + (1.0-opacity)*c2;
}
float blend_exclusion_f(float c1, float c2) {
	return c1 + c2 - 2.0 * c1 * c2;
}
vec3 blend_exclusion(vec2 uv, vec3 c1, vec3 c2, float opacity) {
	return opacity*vec3(blend_exclusion_f(c1.x, c2.x), blend_exclusion_f(c1.y, c2.y), blend_exclusion_f(c1.z, c2.z)) + (1.0-opacity)*c2;
}
const float p_o171246_translate_x = 0.000000000;
const float p_o171246_translate_y = 0.000000000;
const float p_o171246_rotate = 0.000000000;
const float p_o171246_scale_x = 1.000000000;
const float p_o171246_scale_y = 1.000000000;
const float p_o171236_amount1 = 0.100000000;
const float p_o171236_amount2 = 1.000000000;
const float p_o171244_hue = 0.000000000;
const float p_o171244_saturation = 0.563100000;
const float p_o171244_value = 0.859950000;
const float seed_o171227 = 0.734986603;
const float p_o171227_count = 25.000000000;
const float p_o171227_rings = 1.000000000;
const float p_o171227_scale_x = 1.000000000;
const float p_o171227_scale_y = 1.000000000;
const float p_o171227_radius = 0.000000000;
const float p_o171227_spiral = 0.000000000;
const float p_o171227_i_rotate = 0.000000000;
const float p_o171227_i_scale = 0.000000000;
const float p_o171227_rotate = 0.000000000;
const float p_o171227_scale = 0.000000000;
const float p_o171227_value = 0.000000000;
const float seed_o171241 = 0.396753490;
const float p_o171241_rotate = 0.000000000;
const float p_o171241_scale_x = 1.000000000;
const float p_o171241_scale_y = 1.000000000;
const float p_o171232_default_in1 = 0.000000000;
const float p_o171232_default_in2 = 5.000000000;
const float seed_o171233 = 0.220475823;
const float p_o171231_default_in1 = 0.000000000;
const float p_o171231_default_in2 = 5.000000000;
const float p_o171226_sides = 6.000000000;
const float p_o171226_radius = 1.000000000;
const float p_o171226_edge = 1.000000000;
float o171227_input_in(vec2 uv, float _seed_variation_) {
float o171233_0_clamp_false = (elapsed_time*0.01)+(param_rnd(0,1, (seed_o171233+fract(_seed_variation_))+17.841471));
float o171233_0_clamp_true = clamp(o171233_0_clamp_false, 0.0, 1.0);
float o171233_0_2_f = o171233_0_clamp_false;
float o171232_0_clamp_false = cos(o171233_0_2_f*p_o171232_default_in2);
float o171232_0_clamp_true = clamp(o171232_0_clamp_false, 0.0, 1.0);
float o171232_0_2_f = o171232_0_clamp_false;
float o171231_0_clamp_false = sin(o171233_0_2_f*p_o171231_default_in2);
float o171231_0_clamp_true = clamp(o171231_0_clamp_false, 0.0, 1.0);
float o171231_0_2_f = o171231_0_clamp_false;
float o171226_0_1_f = shape_circle((fract(transform2((uv), vec2((param_rnd(-1,1, (seed_o171241+fract(_seed_variation_))+0.841471))*(2.0*o171232_0_2_f-1.0), (param_rnd(-1,1, (seed_o171241+fract(_seed_variation_))+17.841471))*(2.0*o171231_0_2_f-1.0)), p_o171241_rotate*0.01745329251*(2.0*1.0-1.0), vec2(p_o171241_scale_x*(2.0*1.0-1.0), p_o171241_scale_y*(2.0*1.0-1.0))))), p_o171226_sides, p_o171226_radius*1.0, p_o171226_edge*1.0);
vec4 o171241_0_1_rgba = vec4(vec3(o171226_0_1_f), 1.0);
return (dot((o171241_0_1_rgba).rgb, vec3(1.0))/3.0);
}
float o171227_input_mask(vec2 uv, float _seed_variation_) {
return 1.0;
}
vec4 splatter_o171227(vec2 uv, int count, int rings, inout vec3 instance_uv, vec2 seed, float _seed_variation_) {
	float c = 0.0;
	vec3 rc = vec3(0.0);
	vec3 rc1;
	seed = rand2(seed);
	for (int i = 0; i < count; ++i) {
		float a = -1.57079632679+6.28318530718*float(i)*p_o171227_rings/float(count);
		float rings_distance = ceil(float(i+1)*float(rings)/float(count))/float(rings);
		float spiral_distance = float(i+1)/float(count);
		vec2 pos = p_o171227_radius*mix(rings_distance, spiral_distance, p_o171227_spiral)*vec2(cos(a), sin(a));
		float mask = o171227_input_mask(fract(pos-vec2(0.5)), _seed_variation_);
		if (mask > 0.01) {
			vec2 pv = uv-0.5-pos;
			rc1 = rand3(seed);
			seed = rand2(seed);
			float angle = (seed.x * 2.0 - 1.0) * p_o171227_rotate * 0.01745329251 + (a+1.57079632679) * p_o171227_i_rotate;
			float ca = cos(angle);
			float sa = sin(angle);
			pv = vec2(ca*pv.x+sa*pv.y, -sa*pv.x+ca*pv.y);
			pv /= mix(1.0, float(i+1)/float(count+1), p_o171227_i_scale);
			pv /= vec2(p_o171227_scale_x, p_o171227_scale_y);
			pv *= (seed.y-0.5)*2.0*p_o171227_scale+1.0;
			pv += vec2(0.5);
			seed = rand2(seed);
			if (pv != clamp(pv, vec2(0.0), vec2(1.0))) {
				continue;
			}
			vec2 full_uv = pv;
			pv = get_from_tileset( 1.0, seed.x, pv);
			float c1 = o171227_input_in(pv, true ? seed.x : 0.0)*mask*(1.0-p_o171227_value*seed.x);
			c = max(c, c1);
			rc = mix(rc, rc1, step(c, c1));
			instance_uv = mix(instance_uv, vec3(full_uv, seed.x), step(c, c1));
		}
	}
	return vec4(rc, c);
}
const float p_o171235_default_in1 = 0.000000000;
const float p_o171235_default_in2 = 0.000000000;
const float p_o171245_translate_x = 0.000000000;
const float p_o171245_translate_y = 0.000000000;
const float p_o171245_rotate = 0.000000000;
const float p_o171245_scale_x = 1.000000000;
const float p_o171245_scale_y = 1.000000000;
vec3 o171237_input_in(vec2 uv, float _seed_variation_) {
vec3 o171227_0_instance_uv = vec3(0.0);
vec4 o171227_0_rch = splatter_o171227((fract(transform2((uv), vec2(p_o171245_translate_x*(2.0*1.0-1.0), p_o171245_translate_y*(2.0*1.0-1.0)), p_o171245_rotate*0.01745329251*(2.0*1.0-1.0), vec2(p_o171245_scale_x*(2.0*1.0-1.0), p_o171245_scale_y*(2.0*1.0-1.0))))), int(p_o171227_count), int(p_o171227_rings), o171227_0_instance_uv, vec2(float((seed_o171227+fract(_seed_variation_)))), _seed_variation_);vec3 o171227_1_1_rgb = o171227_0_rch.rgb;
vec4 o171245_0_1_rgba = vec4(o171227_1_1_rgb, 1.0);
return ((o171245_0_1_rgba).rgb);
}
float o171237_fct(vec2 uv, float _seed_variation_) {
	vec2 e = vec2(1.0/128.000000000, -1.0/128.000000000);
	vec3 rv = 4.0*o171237_input_in(uv, _seed_variation_);
	rv -= o171237_input_in(uv+e.xy, _seed_variation_);
	rv -= o171237_input_in(uv-e.xy, _seed_variation_);
	rv -= o171237_input_in(uv+e.xx, _seed_variation_);
	rv -= o171237_input_in(uv-e.xx, _seed_variation_);
	rv = abs(rv);
	return max(rv.x, max(rv.y ,rv.z))*128.000000000;
}const float p_o171242_default_in1 = 0.000000000;
const float p_o171242_default_in2 = 128.000000000;
const float p_o171243_value = 0.022800000;
const float p_o171243_width = 0.010000000;
void fragment() {
	float _seed_variation_ = variation;
	vec2 uv = fract(UV);
vec3 o171227_0_instance_uv = vec3(0.0);
vec4 o171227_0_rch = splatter_o171227((fract(transform2((uv), vec2(p_o171246_translate_x*(2.0*1.0-1.0), p_o171246_translate_y*(2.0*1.0-1.0)), p_o171246_rotate*0.01745329251*(2.0*1.0-1.0), vec2(p_o171246_scale_x*(2.0*1.0-1.0), p_o171246_scale_y*(2.0*1.0-1.0))))), int(p_o171227_count), int(p_o171227_rings), o171227_0_instance_uv, vec2(float((seed_o171227+fract(_seed_variation_)))), _seed_variation_);vec3 o171227_1_1_rgb = o171227_0_rch.rgb;
vec4 o171244_0_rbga = vec4(o171227_1_1_rgb, 1.0);
vec3 o171244_0_hsv = rgb_to_hsv(o171244_0_rbga.rgb);
o171244_0_hsv.x += p_o171244_hue;
o171244_0_hsv.y = clamp(o171244_0_hsv.y*p_o171244_saturation, 0.0, 1.0);
o171244_0_hsv.z = clamp(o171244_0_hsv.z*p_o171244_value, 0.0, 1.0);
	vec4 o171244_0_1_rgba = vec4(hsv_to_rgb(o171244_0_hsv), o171244_0_rbga.a);
float o171237_0_1_f = clamp(o171237_fct((fract(transform2((uv), vec2(p_o171246_translate_x*(2.0*1.0-1.0), p_o171246_translate_y*(2.0*1.0-1.0)), p_o171246_rotate*0.01745329251*(2.0*1.0-1.0), vec2(p_o171246_scale_x*(2.0*1.0-1.0), p_o171246_scale_y*(2.0*1.0-1.0))))), _seed_variation_), 0.0, 1.0);
float o171227_0_2_f = o171227_0_rch.a;
vec4 o171234_0_1_rgba = vec4(vec3(1.0)-vec4(vec3(o171227_0_2_f), 1.0).rgb, vec4(vec3(o171227_0_2_f), 1.0).a);
float o171242_0_clamp_false = sin((dot((o171234_0_1_rgba).rgb, vec3(1.0))/3.0)*p_o171242_default_in2);
float o171242_0_clamp_true = clamp(o171242_0_clamp_false, 0.0, 1.0);
float o171242_0_2_f = o171242_0_clamp_false;
float o171235_0_clamp_false = max(o171237_0_1_f,o171242_0_2_f);
float o171235_0_clamp_true = clamp(o171235_0_clamp_false, 0.0, 1.0);
float o171235_0_1_f = o171235_0_clamp_false;
vec3 o171243_0_false = clamp((o171234_0_1_rgba.rgb-vec3(p_o171243_value))/max(0.0001, p_o171243_width)+vec3(0.5), vec3(0.0), vec3(1.0));
vec3 o171243_0_true = vec3(1.0)-o171243_0_false;vec4 o171243_0_1_rgba = vec4(o171243_0_true, o171234_0_1_rgba.a);
vec4 o171236_0_b = o171244_0_1_rgba;
vec4 o171236_0_l;
float o171236_0_a;

o171236_0_l = vec4(vec3(o171235_0_1_f), 1.0);
o171236_0_a = p_o171236_amount1*1.0;
o171236_0_b = vec4(blend_overlay((fract(transform2((uv), vec2(p_o171246_translate_x*(2.0*1.0-1.0), p_o171246_translate_y*(2.0*1.0-1.0)), p_o171246_rotate*0.01745329251*(2.0*1.0-1.0), vec2(p_o171246_scale_x*(2.0*1.0-1.0), p_o171246_scale_y*(2.0*1.0-1.0))))), o171236_0_l.rgb, o171236_0_b.rgb, o171236_0_a*o171236_0_l.a), min(1.0, o171236_0_b.a+o171236_0_a*o171236_0_l.a));

o171236_0_l = o171243_0_1_rgba;
o171236_0_a = p_o171236_amount2*1.0;
o171236_0_b = vec4(blend_lighten((fract(transform2((uv), vec2(p_o171246_translate_x*(2.0*1.0-1.0), p_o171246_translate_y*(2.0*1.0-1.0)), p_o171246_rotate*0.01745329251*(2.0*1.0-1.0), vec2(p_o171246_scale_x*(2.0*1.0-1.0), p_o171246_scale_y*(2.0*1.0-1.0))))), o171236_0_l.rgb, o171236_0_b.rgb, o171236_0_a*o171236_0_l.a), min(1.0, o171236_0_b.a+o171236_0_a*o171236_0_l.a));

vec4 o171236_0_2_rgba = o171236_0_b;
vec4 o171246_0_1_rgba = o171236_0_2_rgba;

	vec4 color_tex = o171246_0_1_rgba;
	color_tex = mix(pow((color_tex + vec4(0.055)) * (1.0 / (1.0 + 0.055)),vec4(2.4)),color_tex * (1.0 / 12.92),lessThan(color_tex,vec4(0.04045)));
	ALBEDO = color_tex.rgb;
	ALPHA = color_tex.a;

}



