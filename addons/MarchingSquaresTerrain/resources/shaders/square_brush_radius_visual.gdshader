shader_type spatial;
render_mode unshaded, depth_test_disabled;

uniform int falloff_mode = 0; // 0: None, 1: Linear, 2: Smooth, 3: Sharp, 4: Plateau, 5: Terraced
uniform int falloff_steps = 5;
uniform sampler2D curve_texture : source_color;

void fragment() {
	if (falloff_mode != 0) {
		vec2 uv = (UV - 0.5) * 2.0;
		float t = max(abs(uv.x), abs(uv.y));
		t = 1.0 - clamp(t, 0.0, 1.0);
		
		float sample = t;
		
		if (falloff_mode == 2) { // SMOOTH (Curve Texture)
			sample = texture(curve_texture, vec2(clamp(t, 0.01, 0.99), 0)).r;
		} else if (falloff_mode == 3) { // SHARP
			sample = pow(t, 2.0);
		} else if (falloff_mode == 4) { // PLATEAU
			sample = smoothstep(0.0, 0.2, t);
		} else if (falloff_mode == 5) { // TERRACED
			float steps = float(falloff_steps) + 1.0;
			sample = floor(t * steps) / (steps - 1.0);
		}
		
		ALPHA = clamp(sample, 0.0, 1.0) * 0.6;
	} else {
		ALPHA = 0.25;
	}
}
