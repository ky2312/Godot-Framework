extends Node2D

@onready var kill_label: Label = %KillLabel
@onready var jump_button: Button = %JumpButton
@onready var router: Label = %Router

func _ready() -> void:
	var mob_model = GameManager.app.get_model(MobModel) as MobModel
	mob_model.kill_count.register_with_init_value(func(kill_count):
		kill_label.text = "在上一个场景中，已击杀 {0} 个小怪。".format([kill_count])
	).unregister_when_node_exit_tree(self)
	router.text = "存在 {0} 个路由记录\n当前路由: {1}".format([len(GameManager.app.router.history), GameManager.app.router.current_route])


func _on_jump_button_pressed() -> void:
	# 跳转前一个
	GameManager.app.router.back()
	# 跳转前一个
	#GameManager.app.router.go(-1)
	# 跳转名为one的路由
	#GameManager.app.router.push("one")
