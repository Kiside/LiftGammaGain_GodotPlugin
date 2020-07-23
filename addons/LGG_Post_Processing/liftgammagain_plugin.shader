shader_type canvas_item;
render_mode unshaded; 

uniform vec4 color_gamma : hint_color = vec4(0.5, 0.5, 0.5, 1.0); 
uniform vec4 color_gain : hint_color = vec4(0.5, 0.5, 0.5, 1.0);
uniform vec4 color_lift : hint_color = vec4(0.5, 0.5 , 0.5, 1.0);



const float a = 0.25;
const float b = 0.333;
const float scale = 0.7;
const vec4 my_color = vec4(0.24, -0.06, 0.13, 1.0);


void fragment()
{
	COLOR = texture(TEXTURE, SCREEN_UV);
	vec3 new_color = COLOR.rgb;
	
	
	float lift_r = color_lift.r * 2.0;
	float lift_g = color_lift.g * 2.0;
	float lift_b = color_lift.b * 2.0;
	
	new_color = new_color * (1.5 - 0.5 * vec3(lift_r,lift_g,lift_b)) + 0.5 * vec3(lift_r,lift_g,lift_b) - 0.5;
	clamp(new_color,0.0,1.0);
	
	
	float gain_r = color_gain.r * 2.0;
	float gain_g = color_gain.g * 2.0;
	float gain_b = color_gain.b * 2.0;
	
	new_color *= vec3(gain_r, gain_g, gain_b); 
	
	float red_channel = color_gamma.r * 2.0;
	float green_channel = color_gamma.g * 2.0;
	float blue_channel = color_gamma.b * 2.0;
	
	COLOR.rgb = pow(new_color, 1.0 / vec3(red_channel,green_channel ,blue_channel));
	clamp(COLOR.rgb, 0.0, 1.0);
	
}