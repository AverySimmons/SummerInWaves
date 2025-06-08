shader_type canvas_item;

uniform float strength = 1;
uniform vec2 direction = vec2(1);

void vertex() {
	// Called for every vertex the material is visible on.
}

void fragment() {
	// Called for every pixel the material is visible on.
	vec2 uv = UV * 2. - 1.;
	vec2 dir = normalize(direction);
	vec2 uv_in_dir = dot(dir, uv) * dir;
	vec2 perp_vect = vec2(-dir.y, dir.x);
	vec2 uv_in_perp = dot(perp_vect, uv) * perp_vect;
	vec2 final_uv = uv_in_dir * strength + uv_in_perp / strength;
	
	final_uv = final_uv / 2. + 0.5;
	
	COLOR.rgba = texture(TEXTURE, final_uv);
}

//void light() {
//	// Called for every pixel for every light affecting the CanvasItem.
//	// Uncomment to replace the default light processing function with this one.
//}
