class_name MobModel extends FrameworkIModel

var count := FrameworkBindableProperty.new(0)

func _init():
	count.value = 100

func on_init():
	pass