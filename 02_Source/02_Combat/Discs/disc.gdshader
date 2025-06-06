shader_type canvas_item;

void vertex() {
	// Called for every vertex the material is visible on.
}

void fragment() {
	// Called for every pixel the material is visible on.
	vec2 uv = UV * 2. - 1.;
	float circ_mask = length(uv) - 0.5;
	circ_mask = 1. - step(0., circ_mask);
	
	float line_mask = step(mod(uv.x + 0.4 * uv.y, 0.2), 0.1);
	
	COLOR.rgb = vec3(.5, 0.3, 0.7) * line_mask + vec3(0.1, 0.03, 0.4);
	COLOR.a = circ_mask;
}

//void light() {
//	// Called for every pixel for every light affecting the CanvasItem.
//	// Uncomment to replace the default light processing function with this one.
//}
