class_name MobKillCommand extends FrameworkICommand

func on_execute(_data):
	var model = self.app.get_model(PlayerModel) as PlayerModel
	model.kill_count.value += 1
	var model_mob = self.app.get_model(MobModel) as MobModel
	model_mob.count.value -= 1
	self.app.logger.debug("怪物被击杀，已击杀：{0}，剩余：{1}".format([model.kill_count.value, model_mob.count.value]))
