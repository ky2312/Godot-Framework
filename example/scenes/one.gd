extends Node2D

@onready var kill_label: Label = %KillLabel
@onready var achievement_label: Label = %AchievementLabel
@onready var kill_button: Button = %KillButton
@onready var router: Label = %Router
var mob_model: MobModel

func _ready() -> void:
	# 读取数据
	mob_model = GameManager.app.get_model(MobModel) as MobModel
	mob_model.kill_count.register_with_init_value(func(kill_count):
		kill_label.text = "已击杀 {0} 次".format([kill_count])
	).unregister_when_node_exit_tree(self)
	
	# 监听数据更新
	GameManager.app.eventbus.register("achievement_kill_count", func(value):
		achievement_label.text = value
	).unregister_when_node_exit_tree(self)
	router.text = "存在 {0} 个路由记录\n当前路由: {1}".format([len(GameManager.app.router.history), GameManager.app.router.current_route])

# 视图层触发命令
func _on_kill_button_pressed() -> void:
	GameManager.app.send_command(MobKillCommand.new())

func _on_jump_button_pressed() -> void:
	GameManager.app.router.push("two")
