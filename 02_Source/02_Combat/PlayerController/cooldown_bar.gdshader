shader_type canvas_item;

uniform sampler2D noise;
uniform float fill_percent = 0.;

void vertex() {
	// Called for every vertex the material is visible on.
}

float distance_to_arc(vec2 uv, vec2 point1, vec2 point2, float radius) {
	vec2 chord = point2 - point1;
	float chord_len = length(chord);
	
	vec2 mid = 0.5 * (point1 + point2);
	vec2 dir = normalize(vec2(-chord.y, chord.x));
	
	float height = sqrt(radius * radius - 0.25 * chord_len * chord_len);
	vec2 center = mid + dir * height;
	
	float angle1 = atan(point1.y - center.y, point1.x - center.x);
	float angle2 = atan(point2.y - center.y, point2.x - center.x);
	
	vec2 delta = uv - center;
	float angle_uv = atan(delta.y, delta.x);
	float center_dist = length(delta);
	
	float clamp_ang = clamp(angle_uv, angle1, angle2);
	
	vec2 arc_point = center + radius * vec2(cos(clamp_ang), sin(clamp_ang));
	
	return length(uv - arc_point);
}


void fragment() {
	// Called for every pixel the material is visible on.
	float radius = 2.75;
	vec2 uv = UV * 2. - 1.;
	uv.x *= 700./300.;
	uv.y += 0.5;
	
	float ran = texture(noise, fract(UV + TIME*0.1)).r * 0.1 - 0.05;
	vec2 dis_uv = uv + ran * 1.5;
	
	vec2 point1 = vec2(-1.5, 0.5);
	vec2 point2 = vec2(1.5, 0.5);
	
	float dist = distance_to_arc(uv, point2, point1, radius);
	float dis_dist = distance_to_arc(dis_uv, point2, point1, radius);
	
	float fill_math = fill_percent * 3.14 - 1.57;
	fill_math = step(dis_uv.x, fill_math);
	
	float bar_fill_mask = step(dist, 0.07 + ran * 0.2) * fill_math;
	
	float bar_outline_mask = step(abs(0.13 - dist), 0.02);
	
	float final_mask = bar_fill_mask + bar_outline_mask;
	
	COLOR.a = final_mask;
	COLOR.rgb = vec3(0.7, 0.6, 0.) * bar_outline_mask;
	COLOR.rgb += vec3(0.4, 0.9, 1.) * bar_fill_mask;
}

//void light() {
//	// Called for every pixel for every light affecting the CanvasItem.
//	// Uncomment to replace the default light processing function with this one.
//}
