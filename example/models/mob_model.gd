class_name MobModelNS

class MobModel extends FrameworkIModel:

	var count := FrameworkBindableProperty.new(0)

	var _config_utility: ConfigUtilityNS.IConfigUtility

	func _init(config_utility: ConfigUtilityNS.IConfigUtility):
		_config_utility = config_utility

	func on_init():
		count.value = _config_utility.get_mob_count()
