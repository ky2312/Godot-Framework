class_name MobModel extends FrameworkIModel

var count := Framework.BindableProperty.new(0)

func on_init():
	count.value = 100
