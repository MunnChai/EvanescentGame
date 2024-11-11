/*
Credit to KobeDev on Youtube: https://www.youtube.com/watch?v=e9-WQg1yMCY
*/
shader_type canvas_item;

uniform sampler2D screen_texture : hint_screen_texture, filter_linear_mipmap;
uniform float lod : hint_range(0.0, 5.0) = 0.0;
//uniform vec4 tint_color = vec4(1.0, 0.0, 0.0, 0.5);

void fragment() {
    vec4 color = textureLod(screen_texture, SCREEN_UV, lod);
    //COLOR = mix(color, tint_color, tint_color.a);
	COLOR = color;
}