class_name MobKillCommand extends FrameworkICommand

func on_execute():
	var player_system := self.context.get_system(PlayerSystem) as PlayerSystem
	player_system.kill_mob()
