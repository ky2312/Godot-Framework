extends Node

var app: Framework.App

func _ready() -> void:
	app = Framework.App.new()
	app.register_system(AchievementSystem)
	app.register_model(MobModel)
	app.register_utility(Storage)
	app.enable_router(get_window())
	app.router.register("one", "res://example/scenes/one.tscn")
	app.router.register("two", "res://example/scenes/two.tscn")
	app.router.set_main_route_name("one")
	app.run()
