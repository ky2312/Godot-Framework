extends Node2D

@onready var kill_label: Label = %KillLabel
@onready var jump_button: Button = %JumpButton
@onready var router: Label = %Router

func _ready() -> void:
	GameManager.app.logger.debug("进入two场景")

	var player_model := GameManager.app.get_container(PlayerModelNS.PlayerModel) as PlayerModelNS.PlayerModel
	player_model.kill_count.register_with_init_value(func(kill_count):
		kill_label.text = "在上一个场景中，已击杀 {0} 个小怪，上次存档点已击杀 {1} 次。".format([kill_count, player_model.achievement_kill_count.value])
	).unregister_when_node_exit_tree(self)
	router.text = "存在 {0} 个路由记录\n当前路由: {1}".format([len(GameManager.app.router.get_history()), GameManager.app.router.get_current_route()])

func _exit_tree() -> void:
	GameManager.app.logger.debug("离开two场景")

func _on_jump_button_pressed() -> void:
	# 跳转前一个
	GameManager.app.router.back()
	# 跳转前一个
	#GameManager.app.router.go(-1)
	# 跳转名为one的路由
	#GameManager.app.router.push("one")
