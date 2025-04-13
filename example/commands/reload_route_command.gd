## 重新加载路由命令
class_name ReloadRouteCommand extends FrameworkICommand

func on_execute():
	var player_system = self.context.get_system(PlayerSystem) as PlayerSystem
	player_system.reload_data()
