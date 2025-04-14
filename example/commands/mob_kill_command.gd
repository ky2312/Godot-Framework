class_name MobKillCommand extends FrameworkICommand

func on_execute():
	var player_system := self.context.get_system(PlayerSystemNS.IPlayerSystem) as PlayerSystemNS.IPlayerSystem
	player_system.kill_mob()
