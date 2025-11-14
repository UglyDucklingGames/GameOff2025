shader_type spatial;
render_mode unshaded, world_vertex_coords;

instance uniform vec3 colour: source_color = vec3(1,1,1);

void vertex() {
	// Deform
	VERTEX.x += sin((VERTEX.y*5.0) + VERTEX.x + TIME) * 0.125;
	VERTEX.z += cos((VERTEX.y*10.0)+ VERTEX.z + TIME) * 0.125;
	VERTEX.y += sin(VERTEX.x*5.0 + VERTEX.z*10.0 + VERTEX.y + TIME) * 0.125;

}

void fragment() {
	ALBEDO = colour;
}
