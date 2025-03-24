class_name StorageUtility extends FrameworkIUtility

func load(path: String) -> Dictionary:
	if FileAccess.file_exists(path):
		var file = FileAccess.open(path, FileAccess.ModeFlags.READ)
		var json_content = file.get_as_text()
		return JSON.parse_string(json_content)
	else:
		return {}

func save(path: String, value):
	var file = FileAccess.open(path, FileAccess.ModeFlags.WRITE)
	file.store_string(JSON.stringify(value))
