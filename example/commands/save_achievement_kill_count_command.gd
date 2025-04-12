class_name SaveAchievementKillCountCommand extends FrameworkICommand

var count: int

func _init(value: int) -> void:
	self.count = value

func on_call():
	var model := self.app.get_model(PlayerModel) as PlayerModel
	model.achievement_kill_count.value = count
	self.app.logger.debug("已保存成就击杀数 %s" % count)
