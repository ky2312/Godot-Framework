extends Node

var app: Framework.App

func _init() -> void:
	app = Framework.App.new()
	app.register_system(AchievementSystem)
	app.register_model(MobModel)
	app.register_utility(Storage)
	app.run()
