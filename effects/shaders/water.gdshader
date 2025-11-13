shader_type spatial;
render_mode specular_disabled, cull_disabled, diffuse_lambert, world_vertex_coords;

uniform sampler2D tex: source_color, filter_nearest_mipmap;
uniform vec2 uv_scale = vec2(1.0, 1.0);
uniform float amplitude = 1.0;
uniform float frequency = 1.0;
uniform float scale = 1.0;

void vertex() {
	VERTEX.y = (sin(VERTEX.x*scale + TIME*frequency) + cos(VERTEX.z*scale + TIME*frequency)) * amplitude;
}

void fragment() {
	if (FRONT_FACING)
	{
		ALPHA = 1.0;
	}
	else
	{
		ALPHA = 0.25;
	}
	ALBEDO = texture(tex, UV * uv_scale).rgb;
}
