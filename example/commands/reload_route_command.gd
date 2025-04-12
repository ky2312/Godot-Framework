## 重新加载路由命令
class_name ReloadRouteCommand extends FrameworkICommand

func on_call():
	self.app.router.go(0)
	self.app.logger.info("reloaded route")
	
	var model_player := self.app.get_model(PlayerModel) as PlayerModel
	var model_mob := self.app.get_model(MobModel) as MobModel
	var diff = model_player.kill_count.value - model_player.achievement_kill_count.value
	model_player.kill_count.value = model_player.achievement_kill_count.value
	model_mob.count.value += diff
	self.app.logger.info("玩家、怪物数据被重置")
