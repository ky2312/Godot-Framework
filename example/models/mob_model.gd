class_name MobModel extends FrameworkIModel

var kill_count = Framework.BindableProperty.new(0)

func on_init():
	var storage = self.app.get_utility(Storage) as Storage
	var data = storage.load("./data")
	if data.has("kill_count"):
		kill_count.value = data["kill_count"]
