extends Node2D

@onready var label: Label = %Label
@onready var label_2: Label = %Label2
@onready var button: Button = %Button
var mob_model: MobModel

func _ready() -> void:
	mob_model = Framework.app.get_system(MobModel) as MobModel
	mob_model.kill_count.register_with_init_value(func(kill_count):
		label.text = "已击杀 %s 次" % kill_count
	).unregister_when_node_exit_tree(self)
	Framework.app.eventbus.register("achievement_kill_count", func(value):
		label_2.text = value
	).unregister_when_node_exit_tree(self)

func _on_button_pressed() -> void:
	Framework.app.send_command(MobKillCommand.new())

func _on_button_2_pressed() -> void:
	get_tree().change_scene_to_file("res://example/scenes/two.tscn")
