extends Node

var app: Framework.App

func _init() -> void:
	app = Framework.App.new()
	app.register_system(AchievementSystem, AchievementSystem.new())
	app.register_model(MobModel, MobModel.new())
	app.register_utility(Storage, Storage.new())
	app.run()
