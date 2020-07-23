tool
extends Control

onready var r_value = $HBoxContainer/Center_r/R_text
onready var g_value = $HBoxContainer/Center_g/G_text
onready var  b_value = $HBoxContainer/Center_b/B_text

# THE VALUE OF THE COLOR CALCULATED
var value_col
# THE CURRENT COLOR VALUE
var current_color 

onready var texture_trackball_size : Vector2 = get_node("texture_trackball").texture.get_size()
onready var texture_trackball_position : Vector2 = get_node("texture_trackball").rect_position


func _ready():
	
	$Title.text = self.name 
	value_col = $value_rect/value_text.text
	current_color = Color.white
	
	if $Title.text == "Lift":
		$Info.set_text("Shadows")
	elif $Title.text == "Gamma":
		$Info.set_text("Midtones")
	elif $Title.text == "Gain":
		$Info.set_text("Light")

	


# THIS METHOD WILL TAKE THE CHOSEN COLOR. 
# THE COLOR WILL BE CONVERTED FROM RGB TO HSV AND IT WILL BE PASSED FOR THE POST PROCESS
func take_rgb(color_input):
	current_color = color_input
	$Gradient_value.self_modulate = current_color
	var color_toshader = RGBtoHSV(color_input)
	
	r_value.set_text(str(convertRGBvalue(color_input.r)))
	g_value.set_text(str(convertRGBvalue(color_input.g)))
	b_value.set_text(str(convertRGBvalue(color_input.b)))
	
#	IF THE NODE HAS A FATHER HE CAN PASS THE HSV COLOR
#	THIS CONDITION IS NOT ESSENTIAL FOR THE PLUGIN DOCK, BUT FOR TRY "Trackball.tsc"
	if get_tree().get_root().get_child(0).name != self.name:
		match self.name:
			"Lift":
				get_parent().set_lift(color_toshader)
			"Gamma":
				get_parent().set_gamma(color_toshader)
			"Gain":
				get_parent().set_gain(color_toshader)
				
	

# THIS METODH WILL TAKE THE CURRENT COLOR. 
# IT USE WHEN THE USER CHANGE THE VALUE 
func take_current_rgb():
	var color_toshader = RGBtoHSV(current_color)
	$Gradient_value.self_modulate = current_color
	
#	IF THE NODE HAS A FATHER HE CAN PASS THE COLOR CALCULATED
	if get_tree().get_root().get_child(0).name != self.name:
		match self.name:
			"Lift":
				get_parent().set_lift(color_toshader)
			"Gamma":
				get_parent().set_gamma(color_toshader)
			"Gain":
				get_parent().set_gain(color_toshader)	
	

# THIS METHOD IS TO CONVERT THE RGB VALUE FROM 0-1 RANGE TO 0-255
func convertRGBvalue(colortoconvert):
	if colortoconvert >= 1.0:
		return 255.0;
	elif colortoconvert <= 0.0:
		return 0.0
	else:
		return floor(colortoconvert * 256.0);
	


# METHOD TO CHANGE THE RGB COLOR CHOSEN TO HSV
# IN THIS WAY THE USER CAN HANDLE THE VALUE OF THE COLOR 
# SINCE THE COLOR WHEEL IS ONLY FOR SATURATE AND HUE VALUES
func RGBtoHSV(color_input):
	var color = Color(convertRGBvalue(color_input.r),convertRGBvalue(color_input.g),convertRGBvalue(color_input.b))
	var hsv = Vector3()
	var cmax = max(color.r, max(color.g,color.b))
	var cmin = min (color.r, min(color.g,color.b))
	var diff = int(cmax - cmin)
	
#	HUE calculation
	if cmax == cmin: 
		hsv.x = 0
	elif cmax == color.r:
		var segment = (color.g - color.b)/diff
		var shift = 0 / 60
		if segment < 0:
			shift = 360/60
		hsv.x =  segment + shift
	elif cmax == color.g:
		var segment = (color.b - color.r)/diff
		var shift = 120/60
		hsv.x =  segment + shift
	elif cmax == color.b:
		var segment = (color.r - color.g)/diff
		var shift = 240 / 60 
		hsv.x = segment + shift
		
	hsv.x *= 60
	hsv.x = round(hsv.x)
#	SATURATION calculation
	if cmax == 0:
		hsv.y = 0
	else:
		hsv.y = round((diff/cmax)*100)
	
#	VALUE 
	hsv.z = int(value_col)
	
	return Color.from_hsv(hsv.x/359,hsv.y/100, hsv.z/100, 1.0)


# METHOD FOR THE RESTORE BUTTON
func _on_RestoreButton_pressed():
	$texture_trackball/TextureRect.restore_position()
	$VSlider.value = 50

# METHOD FOR THE CHANGE OF THE "VALUE"
func _on_VSlider_value_changed(value):
	value_col = value
	$value_rect.change_value(value_col)
	take_current_rgb()
	
	
	
func get_position_from_father():
#	IF THE NODE DOESN'T HAVE A FATHER HE WILL PASS THE POSITION FROM HIM 
	if get_tree().get_root().get_child(0).name == self.name:
		return texture_trackball_position
#	ELSE HE WILL PASS THE POSITION FROM HIS FATHER
	else:
		return get_parent().give_position(self.name)


func convertRange(color_conv):
	return color_conv / 255

func save_position():
	return $texture_trackball/TextureRect.save_position()
	
func load_position(x,y):
	$texture_trackball/TextureRect.load_position(x,y)

func set_value_col(val):
	value_col = val
	$value_rect.change_value(value_col)

func get_value_col():
	return value_col
