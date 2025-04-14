class_name PlayerSystemNS

class IPlayerSystem extends FrameworkISystem:
    func kill_mob():
        pass
        
    func reload_data():
        pass

class PlayerSystem extends IPlayerSystem:
    var _player_model: PlayerModelNS.PlayerModel

    var _mob_model: MobModelNS.MobModel

    func _init(player_model: PlayerModelNS.PlayerModel, mob_model: MobModelNS.MobModel):
        _player_model = player_model
        _mob_model = mob_model

    func kill_mob():
        _player_model.kill_count.value += 1
        _mob_model.count.value -= 1
        self.context.logger.debug("怪物被击杀，已击杀：{0}，剩余：{1}".format([_player_model.kill_count.value, _mob_model.count.value]))

    func reload_data():
        var diff = _player_model.kill_count.value - _player_model.achievement_kill_count.value
        _player_model.kill_count.value = _player_model.achievement_kill_count.value
        _mob_model.count.value += diff
        self.context.logger.info("玩家、怪物数据被重置")
