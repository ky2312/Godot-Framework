extends Node2D

@export var kill_audio: AudioStream
@onready var kill_label: Label = %KillLabel
@onready var mob_label: Label = %MobLabel
@onready var achievement_label: Label = %AchievementLabel
@onready var kill_button: Button = %KillButton
@onready var router: Label = %Router
var model: PlayerModel

func _ready() -> void:
	GameManager.app.logger.debug("进入one场景")
	# 读取数据并监听数据更新
	model = GameManager.app.get_model(PlayerModel) as PlayerModel
	model.kill_count.register_with_init_value(
		func(kill_count):
			kill_label.text = "已击杀 {0} 次，".format([kill_count])
	).unregister_when_node_exit_tree(self)
	model.achievement_kill_count.register_with_init_value(
		func(achievement_kill_count):
			mob_label.text = "上次存档点已击杀 {0} 次。".format([achievement_kill_count])
	).unregister_when_node_exit_tree(self)
	var model_mob = GameManager.app.get_model(MobModel) as MobModel
	model_mob.count.register_with_init_value(
		func(count):
			kill_button.text = "点击击杀1只小怪，剩余 {0} 只".format([count])
	).unregister_when_node_exit_tree(self)
	
	# 监听数据更新
	GameManager.app.eventbus.register("achievement_killed_count", func(value):
		achievement_label.text = value
	).unregister_when_node_exit_tree(self)
	router.text = "存在 {0} 个路由记录\n当前路由: {1}".format([len(GameManager.app.router.history), GameManager.app.router.current_route])

func _exit_tree() -> void:
	GameManager.app.logger.debug("离开one场景")

# 视图层触发命令
func _on_kill_button_pressed() -> void:
	GameManager.app.audio.play_sfx(kill_audio)
	GameManager.app.audio.set_sfx_volume(0.1)
	GameManager.app.send_command(MobKillCommand.new())

func _on_jump_button_pressed() -> void:
	GameManager.app.router.push("two")
