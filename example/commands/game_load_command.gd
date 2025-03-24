class_name GameLoadCommand extends FrameworkICommand

func on_execute():
	var utility = self.app.get_utility(ArchiveUtility) as ArchiveUtility
	#utility.load("./save.cfg")
	utility.load_encrypted_pass("./save.cfg", "123")
