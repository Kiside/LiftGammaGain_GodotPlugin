tool
extends EditorPlugin

var dock
var scene

func _enter_tree():
	dock = preload("res://addons/LGG_Post_Processing/pannello.tscn").instance()
	add_control_to_bottom_panel (dock, "Lift-Gamma-Gain")

func _exit_tree():
	remove_control_from_bottom_panel(dock)
	dock.free()
