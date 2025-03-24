class_name ReloadSystem extends FrameworkISystem

func on_init():
	var model := self.app.get_model(PlayerModel) as PlayerModel
	self.app.eventbus.register(
		self.app.EVENT_NAME_RELOADED,
		func(_v):
			model.kill_count.value = model.achievement_kill_count.value
			self.app.logger.info("玩家数据被重置")
	)
