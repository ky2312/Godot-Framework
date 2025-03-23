class_name MobKillCommand extends FrameworkICommand

func on_execute():
	var mob_model = self.app.get_model(MobModel) as MobModel
	mob_model.kill_count.value += 1
	GameManager.app.logger.debug("怪物被击杀， 已击杀: %s" % mob_model.kill_count.value)
