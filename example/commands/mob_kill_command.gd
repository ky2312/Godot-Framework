class_name MobKillCommand extends Framework.ICommand

func on_execute():
	var mob_model = self.app.get_model(MobModel) as MobModel
	mob_model.kill_count.value += 1
