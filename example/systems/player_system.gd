class_name PlayerSystem extends FrameworkISystem

var player_model: PlayerModel

var mob_model: MobModel

func on_init():
 player_model = self.context.get_model(PlayerModel)
 mob_model = self.context.get_model(MobModel)

func kill_mob():
 player_model.kill_count.value += 1
 mob_model.count.value -= 1
 self.context.logger.debug("怪物被击杀，已击杀：{0}，剩余：{1}".format([player_model.kill_count.value, mob_model.count.value]))

func reload_data():
 var diff = player_model.kill_count.value - player_model.achievement_kill_count.value
 player_model.kill_count.value = player_model.achievement_kill_count.value
 mob_model.count.value += diff
 self.context.logger.info("玩家、怪物数据被重置")
