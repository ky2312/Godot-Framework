class_name ReloadSystem extends FrameworkISystem

func on_init():
	var model_player := self.app.get_model(PlayerModel) as PlayerModel
	var model_mob := self.app.get_model(MobModel) as MobModel
	self.app.eventbus.register(
		self.app.EVENT_NAME_RELOADED_SCENE,
		func(_v):
			var diff = model_player.kill_count.value - model_player.achievement_kill_count.value
			model_player.kill_count.value = model_player.achievement_kill_count.value
			model_mob.count.value += diff
			self.app.logger.info("玩家、怪物数据被重置")
	)
