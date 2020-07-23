tool
extends TextureRect

onready var trackball_Node = get_parent().get_parent()

var origin_position = Vector2()
var mid_value
var is_dragging = false
var previous_mouse_position = Vector2()

onready var trackball_image = preload("res://addons/LGG_Post_Processing/trackball_edit.png")
onready var trackball_size = trackball_image.get_size()

const radius = 100.0
const cx = 100
const cy = 100


var CENTER : Vector2

func _ready():
	CENTER = get_parent().get_rect().size/2
	origin_position = rect_position


func _input(event):
	var mouse_pos : Vector2
	
#	HERE THE MOUSE WILL CALCULATE HIS POSITION RELATIVELY TO THE CENTER OF THE COLOR WHEEL
	if event is InputEventMouseMotion:
		mouse_pos = get_parent().rect_global_position - event.position + CENTER
		mouse_pos = cartesian2polar(mouse_pos.x, mouse_pos.y)
		if mouse_pos.x > radius:
			mouse_pos.x = radius
		mouse_pos = polar2cartesian(mouse_pos.x, mouse_pos.y)
	
	if not is_dragging:
		return
		
#	WHEN THE LEFT BUTTON WAS RELEASED IT WILL CALCULATE THE COLOR OF THAT POSITION
	if event is InputEventMouseButton and !event.pressed and event.button_index == BUTTON_LEFT:	
		previous_mouse_position = Vector2()
		is_dragging = false
		generated_color(rect_position.x, rect_position.y)


#	POSITION OF THE MIDDLE CIRCLE 
	if is_dragging and event is InputEventMouseMotion:
		var ball_pos:Vector2 = (CENTER - mouse_pos) - (self.get_rect().size/2)
		self.rect_position = ball_pos

# THAT METHOD WILL CALCULATE THE CHOSEN COLOR
func generated_color(x,y):
	var rx = x - cx
	var ry = y - cy 
	var s = (pow(pow(rx,2.0) + pow(ry,2.0), 0.5))/radius
	var h = ((atan2(ry,rx)/PI) + 1.0) / 2.0
	var n_col = Color.from_hsv(h,s,1.0)
	self_modulate = n_col
	trackball_Node.take_rgb(n_col)

# METHOD TO RESTORE THE POSITION AND THE COLOR OF THE COLOR WHEEL
func restore_position():
	rect_position = origin_position
	generated_color(100, 100)

# THIS METHOD IS FOR HANDLE THE INPUT EVENT OF THE MOUSE ON THE MIDDLE CIRCLE
func _on_TextureRect_gui_input(event):
	if event is InputEventMouseButton and event.pressed and event.button_index == BUTTON_LEFT:
		get_tree().set_input_as_handled()
		var diff = event.position - rect_position
		previous_mouse_position = event.position
		is_dragging = true

func save_position():
	return rect_position
	
func load_position(x,y):
	self.rect_position = Vector2(x,y)
	
	
