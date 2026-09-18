shader_type canvas_item;

void fragment() {
	vec4 c = texture(TEXTURE, UV);
	if (c.r > 0.59 && c.b > 0.59 && c.g < 0.55 && (c.r + c.b) > c.g * 2.0 + 0.31) {
		c.a = 0.0;
	}
	COLOR = c;
}
