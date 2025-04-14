class_name PlayerModelNS

class IPlayerModel extends FrameworkIModel:
	func get_kill_count() -> FrameworkBindableProperty:
		return
	
	func get_achievement_kill_count() -> FrameworkBindableProperty:
		return

class PlayerModel extends IPlayerModel:
	var kill_count := FrameworkBindableProperty.new(0)

	var achievement_kill_count := FrameworkBindableProperty.new(0)

	func _init():
		pass

	func on_init():
		pass
	
	func get_kill_count():
		return kill_count
	
	func get_achievement_kill_count():
		return achievement_kill_count