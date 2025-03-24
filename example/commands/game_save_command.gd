class_name GameSaveCommand extends FrameworkICommand

func on_execute():
	var utility = self.app.get_utility(ArchiveUtility) as ArchiveUtility
	#utility.save("./save.cfg")
	utility.save_encrypted_pass("./save.cfg", "123")
