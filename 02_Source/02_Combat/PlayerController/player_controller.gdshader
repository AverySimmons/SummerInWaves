shader_type canvas_item;

uniform float sizex = 40.;

void vertex() {
	// Called for every vertex the material is visible on.
}

void fragment() {
	// Called for every pixel the material is visible on.
	vec2 uv = vec2((1. - UV.x) * sizex / 40. - 1., UV.y * 2. - 1.);

	float section_mask = step(uv.x, 0.);
	float arrow_mask = step(-uv.x + abs(uv.y), 1.) * section_mask;

	float shaft_mask = step(abs(uv.y), 0.5) * (1. - section_mask);

	COLOR.a = arrow_mask + shaft_mask;
}

//void light() {
//	// Called for every pixel for every light affecting the CanvasItem.
//	// Uncomment to replace the default light processing function with this one.
//}
