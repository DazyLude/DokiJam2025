shader_type canvas_item;

uniform vec4 color_filter = vec4(1., 1., 1., 1.);

void fragment() {
	COLOR = COLOR * color_filter;
}