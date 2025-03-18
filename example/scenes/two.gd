extends Node2D

@onready var label: Label = %Label
@onready var button: Button = %Button

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var mob_model = GameManager.app.get_model(MobModel) as MobModel
	mob_model.kill_count.register_with_init_value(func(kill_count):
		label.text = label.text % kill_count
	).unregister_when_node_exit_tree(self)


func _on_button_pressed() -> void:
	get_tree().change_scene_to_file("res://example/scenes/one.tscn")
