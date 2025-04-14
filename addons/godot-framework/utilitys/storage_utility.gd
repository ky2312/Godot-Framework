class_name StorageUtilityNS

class IStorageUtility extends FrameworkIUtility:
	var _datas: Array[Dictionary] = [{}]

	func save(path: String, secret_key: String):
		pass

	func load(path: String, secret_key: String):
		pass

	func get_datas() -> Array[Dictionary]:
		return _datas

	func set_datas(value: Array[Dictionary]):
		_datas = value

	func parse_path(path: String) -> Array:
		var dir = ""
		var file_name = ""
		var last_index = path.rfind("/")
		if last_index != -1:
			dir = path.left(last_index)
			file_name = path.right(len(path) - last_index - 1)
		return [dir, file_name]

## cfg格式归档文件
class CfgStorageUtility extends IStorageUtility:
	func on_init() -> void:
		pass

	func save(path: String, secret_key: String):
		var _parsed_path = parse_path(path)
		var dir = _parsed_path[0]
		var file_name = _parsed_path[1]
		if !file_name:
			push_error("Save archive path error.")
			return

		var config = ConfigFile.new()
		var base_data = get_datas()[0]
		for section in base_data:
			for k in base_data[section]:
				config.set_value(section, k, base_data[section][k])
		var err: Error = OK
		err = DirAccess.make_dir_recursive_absolute(dir)
		if err != OK:
			self.context.logger.error(err)
			return

		if secret_key:
			err = config.save_encrypted_pass(path, secret_key)
		else:
			err = config.save(path)
		if err != OK:
			push_error(err)

	func load(path: String, secret_key: String):
		var base_data := {}
		var config = ConfigFile.new()
		var err: Error = OK
		if secret_key:
			err = config.load_encrypted_pass(path, secret_key)
		else:
			err = config.load(path)
		if err != OK:
			push_error("Load failed: {0}.".format([err]))
			return
		for section in config.get_sections():
			var data := {}
			for k in config.get_section_keys(section):
				data.set(k, config.get_value(section, k))
			base_data.set(section, data)
		
		get_datas().clear()
		get_datas().push_back(base_data)

## csv格式归档文件
class CsvStorageUtility extends IStorageUtility:
	func on_init() -> void:
		pass

	func save(path: String, secret_key: String = ""):
		var _parsed_path = parse_path(path)
		var dir = _parsed_path[0]
		var file_name = _parsed_path[1]
		if !file_name:
			push_error("Save archive path error.")
			return
		
		var err = DirAccess.make_dir_recursive_absolute(dir)
		if err:
			push_error(err)
			return
		var file = FileAccess.open(path, FileAccess.ModeFlags.WRITE)
		if !file:
			push_error(FileAccess.get_open_error())
			return

		if len(get_datas()) < 1:
			return
		var keys := []
		for k in get_datas()[0]:
			keys.push_back(k)
		if not file.store_csv_line(PackedStringArray(keys)):
			file.close()
			push_error("Store csv line error.")
			return
		for data in get_datas():
			var values := []
			for k in keys:
				values.push_back(data[k])
			if not file.store_csv_line(PackedStringArray(values)):
				file.close()
				push_error("Store csv line error.")
				return
		file.close()

	func load(path: String, secret_key: String = ""):
		var file := FileAccess.open(path, FileAccess.ModeFlags.READ)
		if not file:
			push_error(FileAccess.get_open_error())
			return

		var keys := []
		var values: Array[Dictionary] = []
		var is_end = false
		while not is_end:
			var data = file.get_csv_line()
			is_end = !data[0]
			if len(keys) == 0:
				keys = data
			elif not is_end:
				var obj = {}
				for i in range(len(keys)):
					obj.set(keys[i], data[i])
				values.push_back(obj)
		set_datas(values)
		file.close()

## json格式归档文件
class JsonStorageUtility extends IStorageUtility:
	func on_init() -> void:
		pass

	func save(path: String, secret_key: String = ""):
		var _parsed_path = parse_path(path)
		var dir = _parsed_path[0]
		var file_name = _parsed_path[1]
		if !file_name:
			push_error("Save archive path error.")
			return
		
		var err = DirAccess.make_dir_recursive_absolute(dir)
		if err:
			push_error(err)
			return
		var file = FileAccess.open(path, FileAccess.ModeFlags.WRITE)
		if !file:
			push_error(FileAccess.get_open_error())
			return

		var str := JSON.stringify(get_datas()[0])
		file.store_string(str)
		file.close()

	func load(path: String, secret_key: String = ""):
		var file := FileAccess.open(path, FileAccess.ModeFlags.READ)
		if not file:
			push_error(FileAccess.get_open_error())
			return

		var json := JSON.new()
		var error := json.parse(file.get_as_text())
		if error != OK:
			file.close()
			push_error(error)
			return
		var data_received = json.data
		get_datas()[0] = data_received
		file.close()
