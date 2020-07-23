tool
extends ColorRect

var value_val = 50

# Called when the node enters the scene tree for the first time.
func _ready():
	change_value(value_val)

func change_value(val):
	value_val = val
	$value_text.text = str(value_val)
