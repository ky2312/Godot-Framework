class_name AchievementSystemNS

class IAchievementSystem extends FrameworkISystem:
	pass

class AchievementSystem extends IAchievementSystem:
	var _player_model: PlayerModelNS.IPlayerModel

	func _init(player_model: PlayerModelNS.IPlayerModel):
		self._player_model = player_model

	func on_init():
		_player_model.get_kill_count().register(
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
					self.context.eventbus.trigger("achievement_killed_count", s)
					self.context.logger.debug(s)

					_player_model.get_achievement_kill_count().value = kill_count
					self.context.logger.debug("已保存成就击杀数 {0}".format([kill_count]))
		)
