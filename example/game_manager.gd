extends Node

var background_music: AudioStream = preload("res://example/assets/music/time_for_adventure.mp3")

var app: Framework

func _ready() -> void:
	app = Framework.new()
	app.register_system(AchievementSystem)
	app.register_model(MobModel)
	app.register_utility(Storage)
	app.enable_router(self)
	app.router.register("one", "res://example/scenes/one.tscn")
	app.router.register("two", "res://example/scenes/two.tscn")
	app.router.set_main_route_name("one")
	app.enable_audio(self)
	app.audio.play_background_music(background_music)
	app.run()
