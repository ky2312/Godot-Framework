extends Node2D

@export var kill_audio: AudioStream
@onready var kill_label: Label = %KillLabel
@onready var mob_label: Label = %MobLabel
@onready var achievement_label: Label = %AchievementLabel
@onready var kill_button: Button = %KillButton
@onready var router: Label = %Router

func _ready() -> void:
	GameManager.app.logger.debug("进入one场景")
	# 读取数据并监听数据更新
	var player_model := GameManager.app.get_container(PlayerModelNS.PlayerModel) as PlayerModelNS.PlayerModel
	var mob_model := GameManager.app.get_container(MobModelNS.MobModel) as MobModelNS.MobModel
	# 两种使用方式
	# 便捷使用多个值
	FrameworkBindableProperty.register_propertys_with_init_value(
		[player_model.kill_count, player_model.achievement_kill_count, mob_model.count],
		func(kill_count, achievement_kill_count, count):
			kill_label.text = "已击杀 {0} 次，".format([kill_count])
			mob_label.text = "上次存档点已击杀 {0} 次。".format([achievement_kill_count])
			kill_button.text = "点击击杀1只小怪，剩余 {0} 只".format([count])
	).unregister_when_node_exit_tree(self)
	# 通常使用单个值
	#player_model.kill_count.register_with_init_value(
		#func(kill_count):
			#kill_label.text = "已击杀 {0} 次，".format([kill_count])
	#).unregister_when_node_exit_tree(self)
	#player_model.achievement_kill_count.register_with_init_value(
		#func(achievement_kill_count):
			#mob_label.text = "上次存档点已击杀 {0} 次。".format([achievement_kill_count])
	#).unregister_when_node_exit_tree(self)
	#mob_model.count.register_with_init_value(
		#func(count):
			#kill_button.text = "点击击杀1只小怪，剩余 {0} 只".format([count])
	#).unregister_when_node_exit_tree(self)
	
	# 监听数据更新
	GameManager.app.eventbus.register("achievement_killed_count", func(value):
		achievement_label.text = value
	).unregister_when_node_exit_tree(self)
	router.text = "存在 {0} 个路由记录\n当前路由: {1}".format([len(GameManager.app.router.get_history()), GameManager.app.router.get_current_route()])

func _exit_tree() -> void:
	GameManager.app.logger.debug("离开one场景")

# 视图层触发命令
func _on_kill_button_pressed() -> void:
	GameManager.app.audio.play_sfx(kill_audio)
	GameManager.app.audio.set_sfx_volume(50)
	GameManager.app.send_command(MobKillCommand.new())

func _on_jump_button_pressed() -> void:
	#GameManager.app.router.push("mob/two")
	GameManager.app.router.push("mob/two", true, RouterUtilityNS.LoadRouterJump.new())
