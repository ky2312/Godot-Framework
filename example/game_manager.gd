extends Node

var app: Framework

func _ready() -> void:
	app = Framework.new()
	var player_model := app.register_container(PlayerModel, PlayerModel.new())
	var mob_model := app.register_container(MobModel, MobModel.new())
	app.register_container(AchievementSystem, AchievementSystem.new(player_model))
	app.register_container(PlayerSystem, PlayerSystem.new(player_model, mob_model))
	# 修改默认存储工具和存档系统
	app.unregister_container(StorageUtilityNS.IStorageUtility)
	app.unregister_container(GameArchiveSystemNS.IGameArchiveSystem)
	var json_storage_utility := app.register_container(StorageUtilityNS.IStorageUtility, StorageUtilityNS.JsonStorageUtility.new()) as StorageUtilityNS.IStorageUtility
	app.register_container(GameArchiveSystemNS.IGameArchiveSystem, GameArchiveSystemNS.GameArchiveSystem.new(json_storage_utility))

	var err = app.run(self)
	if err:
		app.logger.error("启动游戏失败 {0}".format([err]))
		app.quit()
		return
	app.logger.info("启动游戏成功")

	# app.game_archive.configuration("res://.debug/data/save.cfg", "secret_key")
	app.game_archive.configuration("res://.debug/data/save.cfg", "")
	app.game_archive.register_model("player", player_model)
	app.game_archive.register_model("mob", mob_model)
	
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
