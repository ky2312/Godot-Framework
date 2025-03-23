class_name AchievementSystem extends FrameworkISystem

var mob_model: MobModel
func on_init():
	mob_model = self.app.get_model(MobModel) as MobModel
	mob_model.kill_count.register(func(kill_count):
		match kill_count:
			3:
				self.app.eventbus.trigger("achievement_kill_count", "达成普通成就，击杀小怪%s只" % kill_count)
				GameManager.app.logger.debug("达成普通成就，击杀小怪%s只" % kill_count)
			5:
				self.app.eventbus.trigger("achievement_kill_count", "达成白银成就，击杀小怪%s只" % kill_count)
				GameManager.app.logger.debug("达成白银成就，击杀小怪%s只" % kill_count)
			10:
				self.app.eventbus.trigger("achievement_kill_count", "达成黄金成就，击杀小怪%s只" % kill_count)
				GameManager.app.logger.debug("达成黄金成就，击杀小怪%s只" % kill_count)
	)
