// assets/shaders/hit_flash.gdshader
shader_type spatial;

uniform float flash_amount : hint_range(0.0, 1.0) = 0.0;
uniform vec4 flash_color : source_color = vec4(1.0, 1.0, 1.0, 1.0);
uniform vec4 base_color : source_color = vec4(1.0, 1.0, 1.0, 1.0);

void fragment() {
	ALBEDO = mix(base_color.rgb, flash_color.rgb, flash_amount);
	ROUGHNESS = 0.8;
}