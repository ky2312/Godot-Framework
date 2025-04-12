class_name MobModel extends FrameworkIModel

var count := FrameworkBindableProperty.new(0)

func on_init():
	count.value = 100
