class_name MobKillCommand extends FrameworkICommand

func on_execute():
	var model = self.app.get_model(PlayerModel) as PlayerModel
	model.kill_count.value += 1
	self.app.logger.debug("怪物被击杀， 已击杀: %s" % model.kill_count.value)
