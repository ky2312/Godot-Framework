class_name ConfigUtilityNS

class IConfigUtility extends FrameworkIUtility:
    func get_mob_count() -> int:
        return 0

class ConfigUtility extends IConfigUtility:
    var _mob_count: int

    var _storage_utility: StorageUtilityNS.IStorageUtility
    
    func get_mob_count() -> int:
        return _mob_count

    func _init(storage_utility: StorageUtilityNS.IStorageUtility):
        _storage_utility = storage_utility
    
    func on_init():
        _cfg()
        # _json()
    
    func _cfg():
        var configs := {}
        _storage_utility.load_cfg("res://.debug/configs.cfg", "", configs)
        if len(configs) == 0:
            configs = {
                "mob": {
                    "count": 100,
                },
            }
            _storage_utility.save_cfg("res://.debug/configs.cfg", "", configs)
        _mob_count = configs["mob"]["count"]
    
    func _json():
        var configs := {}
        _storage_utility.load_json("res://.debug/configs.json", "", configs)
        if len(configs) == 0:
            configs = {
                "mob": {
                    "count": 200,
                },
            }
            _storage_utility.save_json("res://.debug/configs.json", "", configs)
        _mob_count = configs["mob"]["count"]