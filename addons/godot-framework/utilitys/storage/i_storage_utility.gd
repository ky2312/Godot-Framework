class_name IStorageUtility extends FrameworkIUtility

var datas: Array[Dictionary]

func save(path: String, secret_key: String):
	pass

func load(path: String, secret_key: String):
	pass

func parse_path(path: String) -> Array:
	var dir = ""
	var file_name = ""
	var last_index = path.rfind("/")
	if last_index != -1:
		dir = path.left(last_index)
		file_name = path.right(len(path) - last_index - 1)
	return [dir, file_name]
