extends Node

var background_music: AudioStream = preload("res://example/assets/music/time_for_adventure.mp3")

var app: Framework

func _ready() -> void:
	app = Framework.new(self)
	app.register_system(AchievementSystem)
	app.register_model(PlayerModel)
	app.register_model(MobModel)
	app.register_utility(StorageUtility)
	app.router.register("one", "res://example/scenes/one.tscn")
	app.router.register("two", "res://example/scenes/two.tscn")
	app.audio.play_music(background_music)
	app.audio.set_volume(100)
	app.logger.set_level(app.Logger.LEVEL.DEBUG)
	app.logger.add_renderer(app.Logger.FileRenderer.new())
	var err = app.run()
	if err:
		app.quit()
		return
	
	app.logger.info("启动游戏")
	# 子日志
	var logger = app.logger.create_logger("GameManager")
	logger.debug("在GameManager内部")
