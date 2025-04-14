class_name StorageUtilityNS

class IStorageUtility extends FrameworkIUtility:
	func save_cfg(path: String, secret_key: String, data: Dictionary) -> Error:
		return FAILED

	func load_cfg(path: String, secret_key: String, data: Dictionary) -> Error:
		return FAILED
		
	func save_csv(path: String, secret_key: String, data: Array[Dictionary]) -> Error:
		return FAILED

	func load_csv(path: String, secret_key: String, data: Array[Dictionary]) -> Error:
		return FAILED

	func save_json(path: String, secret_key: String, data: Dictionary) -> Error:
		return FAILED

	func load_json(path: String, secret_key: String, data: Dictionary) -> Error:
		return FAILED

class StorageUtility extends IStorageUtility:
	func save_cfg(path: String, secret_key: String, data: Dictionary) -> Error:
		return CfgStorage.new(context).save(path, secret_key, [data])

	func load_cfg(path: String, secret_key: String, data: Dictionary) -> Error:
		var datas: Array[Dictionary] = []
		var err := CfgStorage.new(context).load(path, secret_key, datas)
		if err != OK:
			return err
		data.clear()
		for k in datas[0]:
			data.set(k, datas[0][k])
		return OK
		
	func save_csv(path: String, secret_key: String, data: Array[Dictionary]) -> Error:
		return CsvStorage.new(context).save(path, secret_key, data)

	func load_csv(path: String, secret_key: String, data: Array[Dictionary]) -> Error:
		return CsvStorage.new(context).load(path, secret_key, data)

	func save_json(path: String, secret_key: String, data: Dictionary) -> Error:
		return JsonStorage.new(context).save(path, secret_key, [data])

	func load_json(path: String, secret_key: String, data: Dictionary) -> Error:
		var datas: Array[Dictionary] = []
		var err := JsonStorage.new(context).load(path, secret_key, datas)
		if err != OK:
			return err
		data.clear()
		for k in datas[0]:
			data.set(k, datas[0][k])
		return OK

class ISubStorage:
	func save(path: String, secret_key: String, datas: Array[Dictionary]) -> Error:
		return FAILED

	func load(path: String, secret_key: String, datas: Array[Dictionary]) -> Error:
		return FAILED

	func parse_path(path: String) -> Array:
		var dir = ""
		var file_name = ""
		var last_index = path.rfind("/")
		if last_index != -1:
			dir = path.left(last_index)
			file_name = path.right(len(path) - last_index - 1)
		return [dir, file_name]

## cfg格式归档文件
class CfgStorage extends ISubStorage:
	var _context: FrameworkIUtility.Context

	func _init(context: FrameworkIUtility.Context) -> void:
		self._context = context

	func save(path: String, secret_key: String, datas: Array[Dictionary]) -> Error:
		if len(datas) == 0:
			return FAILED
		var _parsed_path = parse_path(path)
		var dir = _parsed_path[0]
		var file_name = _parsed_path[1]
		if !file_name:
			push_error("Save archive path error.")
			return FAILED

		var config = ConfigFile.new()
		var base_data = datas[0]
		for k1 in base_data:
			if not base_data[k1] is Dictionary:
				_context.logger.error("The structure is incorrect, the second layer must be a dictionary, name is {0}.".format([k1]))
				return FAILED
			for k2 in base_data[k1]:
				config.set_value(k1, k2, base_data[k1][k2])
		var err: Error = OK
		err = DirAccess.make_dir_recursive_absolute(dir)
		if err != OK:
			self.context.logger.error(err)
			return FAILED

		if secret_key:
			err = config.save_encrypted_pass(path, secret_key)
		else:
			err = config.save(path)
		if err != OK:
			push_error(err)
		return OK

	func load(path: String, secret_key: String, datas: Array[Dictionary]) -> Error:
		var base_data := {}
		var config = ConfigFile.new()
		var err: Error = OK
		if secret_key:
			err = config.load_encrypted_pass(path, secret_key)
		else:
			err = config.load(path)
		if err != OK:
			push_error("Load failed: {0}.".format([err]))
			return FAILED
		for section in config.get_sections():
			var _data := {}
			for k in config.get_section_keys(section):
				_data.set(k, config.get_value(section, k))
			base_data.set(section, _data)
		
		if len(datas) == 0:
			datas.push_back({})
		datas[0] = base_data
		return OK

## csv格式归档文件
## TODO 还需实现加解密功能
class CsvStorage extends ISubStorage:
	var _context: FrameworkIUtility.Context

	func _init(context: FrameworkIUtility.Context) -> void:
		self._context = context

	func save(path: String, secret_key: String, datas: Array[Dictionary]) -> Error:
		if len(datas) == 0:
			return FAILED
		var _parsed_path = parse_path(path)
		var dir = _parsed_path[0]
		var file_name = _parsed_path[1]
		if !file_name:
			push_error("Save archive path error.")
			return FAILED
		
		var err = DirAccess.make_dir_recursive_absolute(dir)
		if err:
			push_error(err)
			return FAILED
		var file = FileAccess.open(path, FileAccess.ModeFlags.WRITE)
		if !file:
			push_error(FileAccess.get_open_error())
			return FAILED

		var keys := []
		for k in datas[0]:
			keys.push_back(k)
		if not file.store_csv_line(PackedStringArray(keys)):
			file.close()
			push_error("Store csv line error.")
			return FAILED
		for data in datas:
			var values := []
			for k in keys:
				values.push_back(data[k])
			if not file.store_csv_line(PackedStringArray(values)):
				file.close()
				push_error("Store csv line error.")
				return FAILED
		file.close()
		return OK

	func load(path: String, secret_key: String, datas: Array[Dictionary]) -> Error:
		var file := FileAccess.open(path, FileAccess.ModeFlags.READ)
		if not file:
			push_error(FileAccess.get_open_error())
			return FAILED

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
		file.close()
		datas.clear()
		for v in values:
			datas.push_back(v)
		return OK

## json格式归档文件
## TODO 还需实现加解密功能
class JsonStorage extends ISubStorage:
	var _context: FrameworkIUtility.Context

	func _init(context: FrameworkIUtility.Context) -> void:
		self._context = context

	func save(path: String, secret_key: String, datas: Array[Dictionary]) -> Error:
		if len(datas) == 0:
			return FAILED
		var _parsed_path = parse_path(path)
		var dir = _parsed_path[0]
		var file_name = _parsed_path[1]
		if !file_name:
			push_error("Save archive path error.")
			return FAILED
		
		var err = DirAccess.make_dir_recursive_absolute(dir)
		if err:
			push_error(err)
			return FAILED
		var file = FileAccess.open(path, FileAccess.ModeFlags.WRITE)
		if !file:
			push_error(FileAccess.get_open_error())
			return FAILED

		var str := JSON.stringify(datas[0])
		file.store_string(str)
		file.close()
		return OK

	func load(path: String, secret_key: String, datas: Array[Dictionary]) -> Error:
		var file := FileAccess.open(path, FileAccess.ModeFlags.READ)
		if not file:
			push_error(FileAccess.get_open_error())
			return FAILED

		var json := JSON.new()
		var error := json.parse(file.get_as_text())
		if error != OK:
			file.close()
			push_error(error)
			return FAILED
		file.close()
		if len(datas) == 0:
			datas.push_back({})
		datas[0] = json.data
		return OK
