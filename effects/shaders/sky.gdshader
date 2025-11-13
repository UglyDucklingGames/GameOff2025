shader_type sky;

uniform sampler2D colour_gradient: source_color, filter_linear, repeat_disable;
uniform float day_progress: hint_range(0.0, 1.0, 0.01) = 0.1;

void sky() {
	COLOR = texture(colour_gradient, vec2(day_progress, 0.0)).rgb;
}
