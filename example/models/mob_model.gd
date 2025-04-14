class_name MobModelNS

class IMobModel extends FrameworkIModel:
	func get_count() -> FrameworkBindableProperty:
		return

class MobModel extends IMobModel:
	var count := FrameworkBindableProperty.new(0)

	func _init():
		count.value = 100

	func on_init():
		pass
	
	func get_count():
		return count