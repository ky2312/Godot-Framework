extends Node

var app: Framework

func _ready() -> void:
	app = Framework.new()
	var storage_utility := app.get_container(StorageUtilityNS.IStorageUtility)
	var config_utility := app.register_container(ConfigUtilityNS.IConfigUtility, ConfigUtilityNS.ConfigUtility.new(storage_utility))
	var player_model := app.register_container(PlayerModelNS.PlayerModel, PlayerModelNS.PlayerModel)
	var mob_model := app.register_container(MobModelNS.MobModel, MobModelNS.MobModel.new(config_utility))
	var text_model := app.register_container(TextModelNS.TextModel, TextModelNS.TextModel)
	app.register_container(AchievementSystemNS.IAchievementSystem, AchievementSystemNS.AchievementSystem.new(player_model))
	app.register_container(PlayerSystemNS.IPlayerSystem, PlayerSystemNS.PlayerSystem.new(player_model, mob_model))

	var err = app.run(self)
	if err:
		app.logger.error("启动游戏失败 {0}".format([err]))
		app.quit()
		return
	app.logger.info("启动游戏成功")

	# app.game_archive.configuration("res://.debug/data/save.json", "secret_key")
	app.game_archive.configuration("res://.debug/data/save.json", "")
	app.game_archive.register_model("player", player_model)
	app.game_archive.register_model("mob", mob_model)
	app.game_archive.register_model("text", text_model)
	
	app.router.register("main", "res://example/views/main.tscn")
	app.router.register("mob/one", "res://example/views/mob/one.tscn")
	app.router.register("mob/two", "res://example/views/mob/two.tscn")
	app.router.register("platform_jump/level_1", "res://example/views/platform_jump/platform_jump_level_1.tscn")
	app.router.register("text/main", "res://example/views/text/text.tscn")
	
	app.logger.set_level(FrameworkLogger.LEVEL.DEBUG)
	app.logger.add_renderer(FrameworkLogger.FileRenderer.new())

	# 子日志
	var logger = app.logger.create_logger("GameManager")
	logger.debug("在GameManager内部")

func _physics_process(delta: float) -> void:
	app.update(delta)
