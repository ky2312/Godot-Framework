extends Node

var background_music: AudioStream = preload("res://example/assets/music/time_for_adventure.mp3")

var app: Framework

func _ready() -> void:
	app = Framework.new()
	app.register_system(AchievementSystem)
	app.register_system(ReloadSystem)
	app.register_model(PlayerModel)
	app.register_model(MobModel)
	app.register_utility(StorageUtility)
	app.enable_router()
	app.enable_audio()
	app.run(self)
	app.logger.set_level(app.Logger.LEVEL.DEBUG)
	app.logger.add_renderer(app.Logger.FileRenderer.new())
	app.router.register("one", "res://example/scenes/one.tscn")
	app.router.register("two", "res://example/scenes/two.tscn")
	app.router.set_main_route_name()
	app.audio.play_background_music(background_music)
	
	app.logger.info("启动游戏")
