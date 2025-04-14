## 重新加载路由命令
class_name ReloadRouteCommand extends FrameworkICommand

func on_execute():
	var player_system = self.context.get_container(PlayerSystemNS.IPlayerSystem) as PlayerSystemNS.IPlayerSystem
	player_system.reload_data()
