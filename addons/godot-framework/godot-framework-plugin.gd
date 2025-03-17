@tool
extends EditorPlugin


func _enter_tree() -> void:
	add_autoload_singleton("Framework", "res://addons/godot-framework/godot-framework.gd")


func _exit_tree() -> void:
	remove_autoload_singleton("Framework")
