## 游戏存档
class_name GameArchiveSystemNS

class IGameArchiveSystem extends FrameworkISystem:
	func configuration(path: String, secret_key: String) -> void:
		pass

	func register_model(name: String, ins: Object):
		pass

	func save():
		pass

	func load():
		pass

class GameArchiveSystem extends IGameArchiveSystem:
	var _path: String

	var _secret_key: String

	## 待处理的模型层实例
	var _models: Dictionary[String, Object]

	var _storage: StorageUtilityNS.IStorageUtility

	func _init(storage: StorageUtilityNS.IStorageUtility):
		self._storage = storage

	func on_init():
		pass

	func configuration(path: String, secret_key: String) -> void:
		self._path = path
		self._secret_key = secret_key

	func register_model(name: String, ins: Object):
		self._models.set(name, ins)

	func save():
		if _check() != OK:
			return
		var base_data := _get_base_data(_models)
		_storage.set_datas([base_data])
		_storage.save(_path, _secret_key)

	func _get_base_data(models: Dictionary[String, Object]) -> Dictionary:
		var base_data := {}
		for model_key in models:
			var model := models.get(model_key) as Object
			var pl := model.get_property_list()
			var section_name := model_key
			var section := {}
			if !section_name:
				break
			for o in pl:
				var property = model.get(o.name)
				if property and property is FrameworkBindableProperty:
					section.set(o.name, model[o.name].value)
			base_data.set(section_name, section)
		return base_data

	func load():
		if _check() != OK:
			return
		_storage.load(_path, _secret_key)
		_set_base_data(_storage.get_datas()[0], _models)

	func _set_base_data(base_data: Dictionary, models: Dictionary[String, Object]):
		for model_key in models:
			var model := models.get(model_key) as Object
			var pl := model.get_property_list()
			var section_name := model_key
			if !section_name:
				break
			if !base_data.has(section_name):
				break
			var section := base_data.get(section_name)
			for key in section:
				if model[key] is FrameworkBindableProperty:
					model[key].value = section[key]

	func _parse_path(path: String) -> Array:
		var dir = ""
		var file_name = ""
		var last_index = path.rfind("/")
		if last_index != -1:
			dir = path.left(last_index)
			file_name = path.right(len(path) - last_index - 1)
		return [dir, file_name]

	func _check() -> Error:
		if not _path:
			self.context.logger.error("The path must be set.")
			return FAILED
		if len(_models) == 0:
			self.context.logger.warning("There is no model data that needs to be saved.")
			return FAILED
		return OK
