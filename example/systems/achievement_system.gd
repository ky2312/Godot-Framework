class_name AchievementSystem extends FrameworkISystem

var model: PlayerModel
func on_init():
	model = self.app.get_model(PlayerModel) as PlayerModel
	model.kill_count.register(
		func(kill_count):
			var s = ""
			match kill_count:
				3:
					s += "达成普通成就，"
				5:
					s += "达成白银成就，"
				10:
					s += "达成黄金成就，"
			if s:
				s += ("击杀小怪%s只" % kill_count)
				self.app.eventbus.trigger("achievement_kill_count", s)
				self.app.send_command(SaveAchievementKillCountCommand.new(kill_count))
				self.app.logger.debug(s)
	)
