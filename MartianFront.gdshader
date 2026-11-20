shader_type canvas_item;
render_mode unshaded;
uniform float age = 0.0;
uniform float strength : hint_range(0.0, 1.0) = 0.0;

float hash21(vec2 p) {
	vec3 r = fract(vec3(p.xyx) * 0.1031);
	r += dot(r, r.yzx + 33.33);
	return fract((r.x + r.y) * r.z);
}
float noise2(vec2 p) {
	vec2 i = floor(p), f = fract(p);
	f = f*f*(3.0-2.0*f);
	return mix(mix(hash21(i), hash21(i+vec2(1,0)), f.x),
	           mix(hash21(i+vec2(0,1)), hash21(i+vec2(1,1)), f.x), f.y);
}
float clouds(vec2 p) {
	float n = noise2(p)*0.54;
	p = p*2.07 + vec2(11.3, 7.2);
	n += noise2(p)*0.28;
	return n + noise2(p*2.13 + 19.7)*0.18;
}
void fragment() {
	vec2 p = UV;
	float glow = exp(-length((p-vec2(0.64,0.29))*vec2(3.6,1.15))*4.8);
	vec4 dust = vec4(0.0);
	// A dust front advances across the hangar as its vertical rolls fold into the haze.
	if (strength > 0.002) {
		float t=age*0.18;
		vec2 q=vec2(p.x*6.1-t*0.86,p.y*2.8);
		float curl=clouds(q*0.85+vec2(0.0,t*0.17));
		float billow=clouds(q*1.85+vec2(curl*2.7,-curl*1.5));
		float head=mix(-0.35,1.38,strength) + 0.16*curl + (p.y-0.5)*0.27;
		float front=1.0-smoothstep(head-0.18,head+0.08,p.x+billow*0.14);
		float crest=0.28 + 0.88*(0.62-curl) + 0.16*sin(q.x+curl*5.0) - 0.12*strength;
		float bank=smoothstep(crest-0.12,crest+0.13,p.y+billow*0.14);
		float streak=clouds(vec2(p.x*3.2-t*1.9,p.y*19.0+curl*1.1));
		float lit=clamp(billow*0.66+curl*0.28+streak*0.22+glow*0.20,0.0,1.0);
		vec3 cloud=mix(vec3(0.20,0.115,0.125),vec3(0.89,0.62,0.40),smoothstep(0.28,0.81,lit));
		cloud += vec3(0.07,0.035,0.012)*(1.0-smoothstep(0.0,0.16,abs(p.y-crest)))*curl;
		float opacity = clamp(front * bank * (0.68 + 0.32 * strength) * smoothstep(0.0, 0.30, strength), 0.0, 1.0);
		float ground = smoothstep(0.69, 1.0, p.y) * strength * streak * 0.62;
		float alpha = ground + opacity * (1.0 - ground);
		vec3 pigment = vec3(0.86, 0.62, 0.41) * ground + cloud * opacity * (1.0 - ground);
		dust = vec4(pigment / max(alpha, 0.0001), alpha);
	}
	COLOR = dust;
}
