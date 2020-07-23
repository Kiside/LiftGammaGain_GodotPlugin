tool
extends Control

# AGGIUNGERE PULSANTE CARICA E SALVA SETTAGGI, IN MODO TALE CHE L'UTENTE POTRà 
# SALVARE E CARICARE L'ULTIMO PUNTO IN CUI ERA E TENERE SOTTO D'OCCHIO IL CAMBIO
var tab_changed = false
const SETTING_PATH = "res://addons/LGG_Post_Processing/setting.json"
onready var LIFT = $Lift.texture_trackball_position
onready var GAMMA = $Gamma.texture_trackball_position
onready var GAIN =  $Gain.texture_trackball_position
const VALUE = 50 

var lift_param = "color_lift"
var gamma_param = "color_gamma"
var gain_param = "color_lift"
var current_lift = Color(0.5, 0.5, 0.5, 1.0)
var current_gamma = Color(0.5, 0.5, 0.5, 1.0)
var current_gain = Color(0.5, 0.5, 0.5, 1.0)


var root_edited 
var environment_node
var current_scene

var gradient_image = Image.new()
var gradient_edit 

onready var is_ok = preload("res://addons/LGG_Post_Processing/ok.png")
onready var is_noOk = preload("res://addons/LGG_Post_Processing/x.png")
onready var is_dk = preload("res://addons/LGG_Post_Processing/dk.png")
var check_status = 2 

onready var lift_position : Vector2 = get_node("Lift/texture_trackball").rect_position
onready var gamma_position : Vector2 = get_node("Gamma/texture_trackball").rect_position
onready var gain_position : Vector2 = get_node("Gain/texture_trackball").rect_position

func _ready():
#	CREATING THE FILE CONFIG
	var file = File.new()
	if !file.file_exists(SETTING_PATH):
		if file.open(SETTING_PATH, File.WRITE) == OK:
			file.close()
		else:
			print("ERROR CREATING THE CONFIG FILE")

#func create_config(file):
#	if file.open(SETTING_PATH, File.WRITE) == OK:
#		file.store_line(to_json(create_section(file, LIFT, VALUE, GAMMA, VALUE, GAIN, VALUE)))
#		file.close()


func create_section(lift, lift_val, gamma, gamma_val, gain, gain_val):
	var section = current_scene
	var data_json = {
		section:
			{
				"Lift" : var2str(lift),
				"Lift value" : lift_val,
				"Gamma" : var2str(gamma),
				"Gamma value" : gamma_val,
				"Gain" : var2str(gain),
				"Gain value" : gain_val,
			}
	}
	return data_json
	
	
func save_config():
	var setting = File.new()
	if setting.open(SETTING_PATH, File.READ_WRITE) == OK:
		var text = setting.get_as_text()
#		IF THE FILE WAS NOT EMPTY
		if text.length() > 0: 
			var data_json = JSON.parse(text)
	#		IF THERE IS THE SCENE SAVED WE WILL MODIFY IT
			if data_json.result.has(current_scene):
	#			var json_scene = data_json.result[current_scene]
				data_json.result[current_scene]["Lift"] = var2str($Lift.save_position())
				data_json.result[current_scene]["Gamma"] = var2str($Gamma.save_position())
				data_json.result[current_scene]["Gain"] = var2str($Gain.save_position())
				data_json.result[current_scene]["Lift value"] = $Lift.get_value_col()
				data_json.result[current_scene]["Gamma value"] = $Gamma.get_value_col()
				data_json.result[current_scene]["Gain value"] = $Gain.get_value_col()
	#		ELSE WE WILL ADD THE SECTION IN THE JSON
			else: 
				data_json[create_section($Lift.save_position(), $Lift.get_value_col(), $Gamma.save_position(), $Gamma.get_value_col(), $Gain.save_position(), $Gain.get_value_col())]
			
			setting.store_line(to_json(data_json.result))
			setting.close()
#		IF THE FILE WAS EMPTY
		else: 
			var data_json = to_json(create_section($Lift.save_position(), $Lift.get_value_col(), $Gamma.save_position(), $Gamma.get_value_col(), $Gain.save_position(), $Gain.get_value_col())) 
			setting.store_line(data_json)
			setting.close()

func load_config():
	var setting = File.new()
	if setting.open(SETTING_PATH, File.READ) == OK:
		var text = setting.get_as_text()
		setting.close()
		if text.length() > 0:
			var data_json = JSON.parse(text)
			if data_json.error == OK:
	#			CHECK IF IN THE JSON EXIST THE SCENE PARAMETERS 
				if data_json.result.has(current_scene):
					var json_scene = data_json.result[current_scene]
					var json_lift_pos = str2var(json_scene["Lift"])
					var json_gamma_pos = str2var(json_scene["Gamma"])
					var json_gain_pos = str2var(json_scene["Gain"])
					var json_lift_value = json_scene["Lift value"]
					var json_gamma_value = json_scene["Gamma value"]
					var json_gain_value = json_scene["Gain value"]
					$Lift.load_position(json_lift_pos.x, json_lift_pos.y)
					$Lift.set_value_col(int(json_lift_value))
					$Gamma.load_position(json_gamma_pos.x, json_gamma_pos.y)
					$Gamma.set_value_col(int(json_gamma_value))
					$Gain.load_position(json_gain_pos.x, json_gain_pos.y)
					$Gain.set_value_col(int(json_gain_value))
#		ERROR
		else:
			print("ERROR DATA PARSING")

func give_position(name_node):
	match name_node:
		"Lift":
			return lift_position
		"Gamma":
			return gamma_position
		"Gain":
			return gain_position



func _physics_process(delta):
#	IF THE DOCK PLUGIN IS ACTIVATED
	if $HBoxContainer2/CheckBox.pressed:
#		HE START CREATING HIS NEW BAISC BLACK/WHITE GRADIENT
		create_gradient()
		if current_scene != get_tree().get_edited_scene_root().filename or current_scene == null:
			current_scene = get_tree().get_edited_scene_root().filename
			root_edited = get_tree().get_edited_scene_root()
			var node_name = $HBoxContainer/Node_name.text
#			SEARCH THE WORLD ENVIRONMENT NODE IN THE CURRENT EDITED SCENE
			if root_edited.name == node_name:
				environment_node = root_edited
			else:
				environment_node = root_edited.find_node(node_name)
			tab_changed = true
#		IF IT DOESN'T FIND THE WORLD ENVIRONMENT NODE IT WILL SHOW AN ERROR ICON
		if environment_node == null:
			$HBoxContainer/Ui_texture.texture = is_noOk
			check_status = 1
#			IF IT FINDS THE WORLD ENVIRONMENT NODE IT WILL SHOW AN "OK" ICON
		else: 
			$HBoxContainer/Ui_texture.texture = is_ok
			check_status = 0
			if tab_changed: 
				load_config()
				tab_changed = false
#	IF THE PLUGIN IS NOT ACTIVATE THE ICON WILL RESET TO "DON'T KNOW"/"UNKNOWN"
	else: 
		if check_status != 2:
			$HBoxContainer/Ui_texture.texture = is_dk
			check_status = 2 

# IN BASE OF WHAT COLOR WHEELS IS EDIT BY THE USER, THE ALGORITHM WILL CALL ONE
# OF THESE 3 METHODS, THAT WILL CHANGE THE CURRENT VALUE OF LIFT, GAMMA OR GAIN
# AND CALL THE POST PROCESS METHOD TO APPLY THE EFFECT
func set_lift(lift_color):
	current_lift = lift_color
	calculate_postprocess()
		
func set_gamma(gamma_color):
	current_gamma = gamma_color
	calculate_postprocess()

func set_gain(gain_color):
	current_gain = gain_color
	calculate_postprocess()

# THIS METHOD WILL CREATE A BASE BLACK&WHITE GRADIENT
func create_gradient():
	gradient_image.create(255, 1, false, Image.FORMAT_RGB8)
	
	gradient_image.lock()
	for i in range(0, gradient_image.get_width()):
		var color = Vector3(i,i,i)
		color = convertRange(color)
		gradient_image.set_pixel(i,0,Color(color.x,color.y,color.z))
	
	gradient_image.set_pixel(gradient_image.get_width()-1,0,Color.white)
	gradient_image.unlock()
	gradient_image.save_png("res://mio_gradiente.png")
	
	gradient_edit = gradient_image
	
	

# THE METHOD CALLED TO CALCULATE THE POST PROCESS 
func calculate_postprocess():
	if $HBoxContainer/Ui_texture.texture == is_ok:
		calculate_lift()
		calculate_gain()
		calculate_gamma()
		gradient_image.lock()
		gradient_image = gradient_edit
		gradient_image.unlock()
		load_to_environment(gradient_image)
		save_config()


func calculate_lift():
	var lift_channel = Vector3(current_lift.r * 2.0, current_lift.g * 2.0, current_lift.b * 2.0)
	gradient_edit.lock()
	for i in range (0, gradient_image.get_width()):
		var vec1 = Vector3(1.5 - 0.5 * lift_channel.x, 1.5 - 0.5 * lift_channel.y, 1.5 - 0.5 * lift_channel.z)
		var vec2 = Vector3(0.5 * lift_channel.x - 0.5, 0.5 * lift_channel.y - 0.5, 0.5 * lift_channel.z - 0.5)
		var vec3 = Vector3(gradient_edit.get_pixel(i,0).r,gradient_edit.get_pixel(i, 0).g, gradient_edit.get_pixel(i, 0).b) 
		var result = vec3  * vec1 + vec2
		var color_result = Color(result.x, result.y, result.z)
		gradient_edit.set_pixel(i, 0, color_result)
	gradient_edit.unlock()

	
func calculate_gamma():
	var gamma_channel = Vector3(1.0/(current_gamma.r * 2.0), 1.0/(current_gamma.g * 2.0), 1.0/(current_gamma.b * 2.0))
	gradient_edit.lock()
	for i in range (0, gradient_image.get_width()):
		var red_pow = pow(gradient_edit.get_pixel(i,0).r, gamma_channel.x)
		var green_pow = pow(gradient_edit.get_pixel(i,0).g, gamma_channel.y)
		var blue_pow = pow (gradient_edit.get_pixel(i,0).b, gamma_channel.z)
		gradient_edit.set_pixel(i, 0, Color(red_pow,green_pow,blue_pow))
	gradient_edit.unlock()

func calculate_gain():
	var gain_channel = Vector3(current_gain.r * 2.0, current_gain.g * 2.0, current_gain.b * 2.0)
	gradient_edit.lock()
	for i in range (0, gradient_image.get_width()):
		var vec_color = Vector3(gradient_edit.get_pixel(i, 0).r, gradient_edit.get_pixel(i, 0).g, gradient_edit.get_pixel(i, 0).b)
		var result =  vec_color * gain_channel
		gradient_edit.set_pixel(i, 0, Color(result.x, result.y, result.z))
	gradient_edit.unlock()
	

# THIS METHOD WILL LOAD THE NEW GRADIENT IN THE ENVIRONMENT NODE 
func load_to_environment(new_gradient):
	var texture_gradient = ImageTexture.new()
	texture_gradient.create_from_image(new_gradient, 7)
	var env = environment_node.get_environment()
	if env.adjustment_enabled:
		env.set_adjustment_color_correction(texture_gradient)


# THIS METHOD IS USED TO CONVERT THE RANGE OF THE PASSED COLOR TO 0-1
func convertRange(color_conv):
	return color_conv / 255
