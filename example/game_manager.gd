extends Node

func _init() -> void:
	Framework.app.register_system(AchievementSystem, AchievementSystem.new())
	Framework.app.register_model(MobModel, MobModel.new())
	Framework.app.register_utility(Storage, Storage.new())
	Framework.app.run()
