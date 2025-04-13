extends Node

var app: Framework

func _init() -> void:
	app = Framework.new()
	app.register_system(AchievementSystem)
	app.register_system(PlayerSystem)
	app.register_model(PlayerModel)
	app.register_model(MobModel)
	
	#app.game_archive.configuration("user://game/data/save.cfg", "secret_key")
	app.game_archive.configuration("res://.output/data/save.cfg", "")
	app.game_archive.register_model("player", PlayerModel)
	app.game_archive.register_model("mob", MobModel)
	
	app.router.register("main", "res://example/views/main.tscn")
	app.router.register("mob/one", "res://example/views/mob/one.tscn")
	app.router.register("mob/two", "res://example/views/mob/two.tscn")
	app.router.register("platform_jump/level_1", "res://example/views/platform_jump/platform_jump_level_1.tscn")
	app.router.register("text/main", "res://example/views/text/text.tscn")
	
	app.logger.set_level(FrameworkLogger.LEVEL.DEBUG)
	app.logger.add_renderer(FrameworkLogger.FileRenderer.new())

func _ready() -> void:
	var err = app.run(self)
	if err:
		app.logger.error("启动游戏失败 {0}".format([err]))
		app.quit()
		return
	app.logger.info("启动游戏成功")

	# 子日志
	var logger = app.logger.create_logger("GameManager")
	logger.debug("在GameManager内部")

func _process(delta: float) -> void:
	app.update(delta)