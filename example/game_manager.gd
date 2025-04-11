extends Node

var app: Framework

func _init() -> void:
	app = Framework.new()
	app.register_system(AchievementSystem)
	app.register_model(PlayerModel)
	app.register_model(MobModel)
	
	app.game_archive.configuration("user://game/data/save.cfg", "")
	#app.game_archive.configuration("user://game/data/save.cfg", "123")
	app.game_archive.register_model("player", app.get_model(PlayerModel))
	app.game_archive.register_model("mob", app.get_model(MobModel))
	
	app.router.register("one", "res://example/scenes/one.tscn")
	app.router.register("two", "res://example/scenes/two.tscn")
	
	app.logger.set_level(LoggerUtility.LEVEL.DEBUG)
	app.logger.add_renderer(LoggerUtility.FileRenderer.new())

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
