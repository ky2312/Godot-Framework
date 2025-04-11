## 保存存档命令
class_name SaveArchiveCommand extends FrameworkICommand

var path: String

var secret_key: String

func _init(path: String, secret_key: String) -> void:
	self.path = path
	self.secret_key = secret_key

func on_execute():
	var utility = self.app.get_utility(ArchiveUtility) as ArchiveUtility
	if not secret_key:
		utility.save(path)
	else:
		utility.save_encrypted(path, secret_key)
