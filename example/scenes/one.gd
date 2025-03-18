extends Node2D

@onready var label: Label = %Label
@onready var label_2: Label = %Label2
@onready var button: Button = %Button
var mob_model: MobModel

func _ready() -> void:
	# 读取数据
	mob_model = GameManager.app.get_model(MobModel) as MobModel
	mob_model.kill_count.register_with_init_value(func(kill_count):
		label.text = "已击杀 %s 次" % kill_count
	).unregister_when_node_exit_tree(self)
	
	# 监听数据更新
	GameManager.app.eventbus.register("achievement_kill_count", func(value):
		label_2.text = value
	).unregister_when_node_exit_tree(self)

# 视图层触发命令
func _on_button_pressed() -> void:
	GameManager.app.send_command(MobKillCommand.new())

func _on_button_2_pressed() -> void:
	get_tree().change_scene_to_file("res://example/scenes/two.tscn")
